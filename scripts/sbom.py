#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 Romain Pelletant
# SPDX-License-Identifier: Apache-2.0
"""Generates a CycloneDX 1.6 SBOM (JSON) of UTD and all its dependencies.

Components:
  - Flutter SDK (framework + engine) and Dart SDK, compiled into the app
  - Dart packages, from `flutter pub deps --json` and pubspec.lock (SHA-256).
    Dev-only packages are listed with scope "excluded" (they don't ship);
    --runtime-only leaves them out.
  - Native dependencies added by plugins:
      macOS    CocoaPods from macos/Podfile.lock (and Swift packages pinned in
               Package.resolved if Swift Package Manager is enabled)
      Windows  NuGet packages downloaded by plugin CMakeLists.txt
      Linux    system libraries found with pkg_check_modules (versions from
               pkg-config when run on Linux, e.g. in the release container)
      System web engines: Apple WebKit (macOS), Edge WebView2 Runtime (Windows)
  - Licenses from pub.dev, GitHub and NuGet (skip with --offline)

Each component has a "utd:platform" property (all, macos, windows, linux,
android, ios, web) and the dependency graph links every native dependency to
the plugin that pulls it.

Usage:
  scripts/sbom.py [-o FILE] [--runtime-only] [--offline]

SOURCE_DATE_EPOCH, when set, is used as the SBOM timestamp.
"""
import argparse
import concurrent.futures
import datetime
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import urllib.parse
import urllib.request
import uuid
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

APP = {
    "name": "UTD",
    "description": "Desktop client for YouTrack",
    "publisher": "Romain Pelletant",
    "license": "Apache-2.0",
    "vcs": "https://github.com/romainpelletant/utrack-desktop",
}

SPM_RESOLVED = ROOT / "macos/Runner.xcworkspace/xcshareddata/swiftpm/Package.resolved"
PODFILE_LOCK = ROOT / "macos/Podfile.lock"
COCOAPODS_SPECS = Path.home() / ".cocoapods/repos/trunk/Specs"

# Web engines provided by the operating system, used by these plugins.
SYSTEM_WEB_ENGINES = {
    "flutter_inappwebview_macos": {
        "name": "Apple WebKit (WKWebView)",
        "platform": "macos",
        "description": "System web engine of macOS, updated with the OS",
        "url": "https://developer.apple.com/documentation/webkit",
    },
    "flutter_inappwebview_windows": {
        "name": "Microsoft Edge WebView2 Runtime",
        "platform": "windows",
        "description": "Evergreen web engine installed with Windows 10/11",
        "url": "https://developer.microsoft.com/microsoft-edge/webview2/",
    },
}

# pub.dev license tags are lowercase SPDX identifiers; CycloneDX expects the
# canonical spelling for "id". Unknown ones are reported by name.
SPDX_IDS = {
    i.lower(): i
    for i in [
        "MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause", "ISC", "Zlib",
        "MPL-2.0", "Unlicense", "CC0-1.0", "BSL-1.0", "0BSD", "Artistic-2.0",
        "GPL-2.0", "GPL-3.0", "LGPL-2.1", "LGPL-3.0", "AGPL-3.0", "EPL-2.0",
        "BSD-3-Clause-Clear", "WTFPL", "Python-2.0", "MIT-0",
    ]
}
# pub.dev tags describing a license rather than naming it.
NON_LICENSE_TAGS = {"fsf-libre", "osi-approved", "unknown"}

# Federated plugin implementations, by package name suffix.
PLATFORM_SUFFIXES = {
    "_android": "android", "_ios": "ios", "_macos": "macos", "_windows": "windows",
    "_linux": "linux", "_web": "web", "_darwin": "macos,ios", "_foundation": "macos,ios",
}


def warn(message):
    print(f"warning: {message}", file=sys.stderr)


def run(*cmd):
    return subprocess.run(cmd, cwd=ROOT, check=True, capture_output=True, text=True).stdout


def run_json(*cmd):
    out = run(*cmd)
    return json.loads(out[out.index("{"):])  # flutter may print notices first


def fetch_json(url):
    request = urllib.request.Request(url, headers={"User-Agent": "utd-sbom"})
    with urllib.request.urlopen(request, timeout=20) as response:
        return json.load(response)


def license_entry(spdx_or_name):
    key = spdx_or_name.lower()
    return {"license": {"id": SPDX_IDS[key]} if key in SPDX_IDS else {"name": spdx_or_name}}


def property_list(**values):
    return [{"name": f"utd:{k.replace('_', '-')}", "value": v} for k, v in values.items() if v]


# ── License lookups (network) ────────────────────────────────────────────────

def pub_dev_licenses(name):
    try:
        tags = fetch_json(f"https://pub.dev/api/packages/{name}/score").get("tags", [])
    except Exception as e:  # noqa: BLE001 - a missing license must not fail the SBOM
        warn(f"no license for {name}: {e}")
        return []
    names = [t.split(":", 1)[1] for t in tags if t.startswith("license:")]
    return [license_entry(n) for n in names if n not in NON_LICENSE_TAGS]


def github_licenses(repo_url):
    m = re.match(r"https://github\.com/([^/]+/[^/.]+)", repo_url)
    if not m:
        return []
    try:
        spdx = fetch_json(f"https://api.github.com/repos/{m.group(1)}/license")["license"]["spdx_id"]
    except Exception as e:  # noqa: BLE001
        warn(f"no license for {repo_url}: {e}")
        return []
    return [license_entry(spdx)] if spdx and spdx != "NOASSERTION" else []


def nuget_licenses(name, version):
    url = (f"https://api.nuget.org/v3/registration5-semver1/"
           f"{name.lower()}/{version.lower()}.json")
    try:
        entry = fetch_json(url)["catalogEntry"]
        if isinstance(entry, str):
            entry = fetch_json(entry)
    except Exception as e:  # noqa: BLE001
        warn(f"no license for {name}: {e}")
        return []
    if expression := entry.get("licenseExpression"):
        return [{"expression": expression}]
    if entry.get("licenseFile"):
        # License text embedded in the package, without an SPDX identifier.
        return [{"license": {
            "name": f"{name} license",
            "url": f"https://www.nuget.org/packages/{name}/{version}/license",
        }}]
    return []


# ── Native dependency discovery ──────────────────────────────────────────────

def package_dirs():
    """{package: root directory} from .dart_tool/package_config.json."""
    config_path = ROOT / ".dart_tool/package_config.json"
    config = json.loads(config_path.read_text())
    dirs = {}
    for p in config["packages"]:
        uri = p["rootUri"]
        if uri.startswith("file://"):
            dirs[p["name"]] = Path(urllib.parse.unquote(urllib.parse.urlparse(uri).path))
        else:
            dirs[p["name"]] = (config_path.parent / uri).resolve()
    return dirs


def lock_hashes():
    """{package: sha256} from pubspec.lock (hosted packages only)."""
    hashes, current = {}, None
    for line in (ROOT / "pubspec.lock").read_text().splitlines():
        if m := re.match(r"^  ([\w-]+):$", line):
            current = m.group(1)
        elif current and (m := re.match(r'^      sha256: "?([0-9a-f]{64})"?$', line)):
            hashes[current] = m.group(1)
    return hashes


def swift_packages(dirs):
    """Pinned Swift packages and the plugins that declare them."""
    if not SPM_RESOLVED.exists():
        return []
    pins = json.loads(SPM_RESOLVED.read_text()).get("pins", [])
    users = {}
    for name, path in dirs.items():
        for manifest in path.glob("macos/*/Package.swift"):
            for url in re.findall(r'\.package\(\s*url:\s*"([^"]+)"', manifest.read_text()):
                users.setdefault(url.removesuffix(".git").lower(), []).append(name)
    result = []
    for pin in pins:
        location = pin["location"].removesuffix(".git")
        host_path = re.sub(r"^https?://", "", location)
        version = pin["state"].get("version") or pin["state"].get("revision")
        result.append({
            "name": pin["identity"],
            "version": version,
            "purl": f"pkg:swift/{host_path}@{version}",
            "vcs": location,
            "revision": pin["state"].get("revision"),
            "used_by": users.get(location.lower(), []),
        })
    return result


def cocoapods_packages(dirs, offline):
    """Pods from a spec repo (not the plugins themselves) in Podfile.lock.

    Metadata comes from the local trunk spec cache filled by `pod install`,
    or from the CocoaPods CDN when it is missing (e.g. on Linux).
    """
    if not PODFILE_LOCK.exists():
        return []
    text = PODFILE_LOCK.read_text()
    versions, users, current = {}, {}, None
    pods_section = text.split("\nDEPENDENCIES:")[0]
    for line in pods_section.splitlines():
        if m := re.match(r"^  - (\S+) \(([^)]+)\):?$", line):
            current = m.group(1)
            versions[current] = m.group(2)
        elif current and (m := re.match(r"^    - (\S+)", line)):
            users.setdefault(m.group(1), []).append(current)
    repo_pods = re.findall(r"^    - (\S+)$", text.split("SPEC REPOS:")[1].split("\n\n")[0],
                           re.MULTILINE) if "SPEC REPOS:" in text else []
    checksums = dict(re.findall(r"^  (\S+): ([0-9a-f]{40})$", text, re.MULTILINE))

    result = []
    for name in repo_pods:
        version = versions.get(name)
        digest = hashlib.md5(name.encode()).hexdigest()
        relative = f"{digest[0]}/{digest[1]}/{digest[2]}/{name}/{version}/{name}.podspec.json"
        spec_path = COCOAPODS_SPECS / relative
        spec = {}
        if spec_path.exists():
            spec = json.loads(spec_path.read_text())
        elif not offline:
            try:
                spec = fetch_json(f"https://cdn.cocoapods.org/Specs/{relative}")
            except Exception as e:  # noqa: BLE001
                warn(f"no podspec for {name}: {e}")
        license_info = spec.get("license")
        license_type = license_info.get("type") if isinstance(license_info, dict) else license_info
        result.append({
            "name": name,
            "version": version,
            "license": license_type,
            "vcs": (spec.get("source") or {}).get("git") or spec.get("homepage"),
            "checksum": checksums.get(name),
            "used_by": [u for u in users.get(name, []) if u in dirs],
        })
    return result


def nuget_packages(dirs):
    """NuGet packages installed by plugins' windows/CMakeLists.txt."""
    result = []
    for plugin, path in sorted(dirs.items()):
        cmake = path / "windows/CMakeLists.txt"
        if not cmake.exists():
            continue
        text = cmake.read_text()
        variables = dict(re.findall(r'set\(\s*(\w+)\s+"([^"]+)"\s*\)', text))
        for name, version in re.findall(r"install\s+([\w.]+)\s+-Version\s+(\S+)", text):
            version = re.sub(r"\$\{(\w+)\}", lambda m: variables.get(m.group(1), m.group(0)), version)
            result.append({"name": name, "version": version, "used_by": [plugin]})
    return result


def pkg_config_modules(dirs):
    """System libraries from pkg_check_modules() in the app and plugin CMake files.

    Versions come from pkg-config when the module is installed (on Linux).
    Optional modules (QUIET) are alternatives picked at build time: on Linux
    only the ones found are listed; elsewhere all are, marked as alternatives.
    """
    sources = [("utrack_desktop", ROOT / "linux/CMakeLists.txt")]
    sources += [(name, path / "linux/CMakeLists.txt") for name, path in sorted(dirs.items())]
    has_pkg_config = shutil.which("pkg-config") is not None
    modules = {}
    for owner, cmake in sources:
        if not cmake.exists():
            continue
        for args in re.findall(r"pkg_check_modules\(([^)]*)\)", cmake.read_text()):
            words = args.split()
            required = "REQUIRED" in words
            for word in words[1:]:
                if word in ("REQUIRED", "QUIET", "IMPORTED_TARGET") or word.startswith("$"):
                    continue
                module = re.split(r"[<>=]", word)[0]
                version = None
                if has_pkg_config:
                    try:
                        version = run("pkg-config", "--modversion", module).strip()
                    except subprocess.CalledProcessError:
                        pass
                if version is None and not required and has_pkg_config:
                    continue
                entry = modules.setdefault(module, {
                    "name": module, "version": version, "used_by": [],
                    "alternative": not required and not has_pkg_config,
                })
                if owner not in entry["used_by"]:
                    entry["used_by"].append(owner)
    if not has_pkg_config:
        warn("pkg-config not found: Linux system library versions are unknown")
    return list(modules.values())


# ── SBOM ─────────────────────────────────────────────────────────────────────

def reachable(packages, roots):
    seen, stack = set(), list(roots)
    while stack:
        name = stack.pop()
        if name in seen or name not in packages:
            continue
        seen.add(name)
        stack.extend(packages[name]["dependencies"])
    return seen


def dart_platform(name, source):
    if source == "sdk":
        return "all"
    for suffix, platform in PLATFORM_SUFFIXES.items():
        if name.endswith(suffix):
            return platform
    return "all"


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("-o", "--output", help="output file (default: stdout)")
    parser.add_argument("--runtime-only", action="store_true",
                        help="leave out dev-only Dart packages")
    parser.add_argument("--offline", action="store_true",
                        help="do not query pub.dev, GitHub and NuGet for licenses")
    args = parser.parse_args()

    deps = run_json("flutter", "pub", "deps", "--json")
    flutter = run_json("flutter", "--version", "--machine")
    packages = {p["name"]: p for p in deps["packages"]}
    root = packages.pop(deps["root"])
    hashes = lock_hashes()
    dirs = package_dirs()

    runtime = reachable(packages, root["directDependencies"])
    dart_names = sorted(n for n in packages if n in runtime or not args.runtime_only)
    swift = swift_packages(dirs)
    pods = cocoapods_packages(dirs, args.offline)
    nuget = nuget_packages(dirs)
    system_libs = pkg_config_modules(dirs)

    flutter_version = flutter["frameworkVersion"]
    dart_version = flutter["dartSdkVersion"].split(" ")[0]
    app_version = root["version"].split("+")[0]
    app_ref = f"utrack-desktop@{app_version}"
    flutter_ref = f"pkg:github/flutter/flutter@{flutter_version}"
    dart_ref = f"pkg:github/dart-lang/sdk@{dart_version}"

    def dart_ref_of(name):
        if packages[name]["source"] == "sdk":
            return f"flutter-sdk:{name}@{flutter_version}"
        return f"pkg:pub/{name}@{packages[name]['version']}"

    # Licenses, fetched in parallel.
    licenses = {}
    if not args.offline:
        jobs = {("pub", n): (pub_dev_licenses, n)
                for n in dart_names if packages[n]["source"] == "hosted"}
        jobs.update({("swift", s["name"]): (github_licenses, s["vcs"]) for s in swift})
        jobs.update({("nuget", n["name"]): (nuget_licenses, n["name"], n["version"]) for n in nuget})
        with concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
            futures = {key: pool.submit(fn, *fn_args) for key, (fn, *fn_args) in jobs.items()}
            licenses = {key: f.result() for key, f in futures.items()}

    components = []
    depends_on = {app_ref: {flutter_ref, dart_ref}}

    # Toolchain compiled into the app.
    components += [
        {
            "type": "framework", "bom-ref": flutter_ref, "name": "Flutter SDK",
            "version": flutter_version, "purl": flutter_ref, "scope": "required",
            "description": "Flutter framework and engine, compiled into the app",
            "licenses": [{"license": {"id": "BSD-3-Clause"}}],
            "externalReferences": [{"type": "vcs", "url": flutter["repositoryUrl"]}],
            "properties": property_list(
                platform="all",
                framework_revision=flutter["frameworkRevision"],
                engine_revision=flutter.get("engineRevision"),
            ),
        },
        {
            "type": "framework", "bom-ref": dart_ref, "name": "Dart SDK",
            "version": dart_version, "purl": dart_ref, "scope": "required",
            "description": "Dart runtime, compiled into the app",
            "licenses": [{"license": {"id": "BSD-3-Clause"}}],
            "externalReferences": [{"type": "vcs", "url": "https://github.com/dart-lang/sdk"}],
            "properties": property_list(platform="all"),
        },
    ]

    # Dart packages.
    listed = set(dart_names)
    for name in dart_names:
        p = packages[name]
        ref = dart_ref_of(name)
        component = {
            "type": "library", "bom-ref": ref, "name": name,
            "scope": "required" if name in runtime else "excluded",
            "properties": property_list(platform=dart_platform(name, p["source"])),
        }
        if p["source"] == "sdk":
            # SDK packages report version 0.0.0; they ship with Flutter.
            component["version"] = flutter_version
            component["description"] = "Package of the Flutter SDK"
            # sky_engine bundles third-party code under several licenses.
            if name != "sky_engine":
                component["licenses"] = [{"license": {"id": "BSD-3-Clause"}}]
            depends_on.setdefault(ref, set()).add(flutter_ref)
        else:
            component["version"] = p["version"]
            component["purl"] = ref
            if name in hashes:
                component["hashes"] = [{"alg": "SHA-256", "content": hashes[name]}]
            if licenses.get(("pub", name)):
                component["licenses"] = licenses[("pub", name)]
            component["externalReferences"] = [{
                "type": "distribution",
                "url": f"https://pub.dev/packages/{name}/versions/{p['version']}",
            }]
        components.append(component)
        depends_on.setdefault(ref, set()).update(
            dart_ref_of(d) for d in p["dependencies"] if d in listed)
    depends_on[app_ref].update(dart_ref_of(n) for n in root["dependencies"] if n in listed)

    def link(used_by, ref):
        for owner in used_by:
            owner_ref = app_ref if owner == deps["root"] else (
                dart_ref_of(owner) if owner in listed else None)
            if owner_ref:
                depends_on.setdefault(owner_ref, set()).add(ref)

    # macOS: Swift packages.
    for s in swift:
        components.append({
            "type": "library", "bom-ref": s["purl"], "name": s["name"],
            "version": s["version"], "purl": s["purl"], "scope": "required",
            **({"licenses": licenses[("swift", s["name"])]}
               if licenses.get(("swift", s["name"])) else {}),
            "externalReferences": [{"type": "vcs", "url": s["vcs"]}],
            "properties": property_list(platform="macos", package_manager="swiftpm",
                                        revision=s["revision"]),
        })
        link(s["used_by"], s["purl"])

    # macOS: CocoaPods.
    for pod in pods:
        purl = f"pkg:cocoapods/{pod['name']}@{pod['version']}"
        component = {
            "type": "library", "bom-ref": purl, "name": pod["name"],
            "version": pod["version"], "purl": purl, "scope": "required",
            "properties": property_list(platform="macos", package_manager="cocoapods",
                                        podspec_sha1=pod["checksum"]),
        }
        if pod["license"]:
            component["licenses"] = [license_entry(pod["license"])]
        if pod["vcs"]:
            component["externalReferences"] = [{"type": "vcs", "url": pod["vcs"]}]
        components.append(component)
        link(pod["used_by"], purl)

    # Windows: NuGet packages.
    for n in nuget:
        purl = f"pkg:nuget/{n['name']}@{n['version']}"
        components.append({
            "type": "library", "bom-ref": purl, "name": n["name"],
            "version": n["version"], "purl": purl, "scope": "required",
            **({"licenses": licenses[("nuget", n["name"])]}
               if licenses.get(("nuget", n["name"])) else {}),
            "externalReferences": [{
                "type": "distribution",
                "url": f"https://www.nuget.org/packages/{n['name']}/{n['version']}",
            }],
            "properties": property_list(platform="windows", package_manager="nuget"),
        })
        link(n["used_by"], purl)

    # Linux: system libraries (dynamically linked, provided by the distribution).
    for lib in system_libs:
        ref = f"pkg-config:{lib['name']}@{lib['version'] or 'unknown'}"
        component = {
            "type": "library", "bom-ref": ref, "name": lib["name"], "scope": "required",
            "description": "System library provided by the Linux distribution",
            "properties": property_list(
                platform="linux", package_manager="pkg-config",
                alternative="one of the alternative backends, chosen at build time"
                if lib["alternative"] else None,
            ),
        }
        if lib["version"]:
            component["version"] = lib["version"]
        components.append(component)
        link(lib["used_by"], ref)

    # System web engines.
    for plugin, engine in SYSTEM_WEB_ENGINES.items():
        if plugin not in listed:
            continue
        ref = f"system:{engine['name']}"
        components.append({
            "type": "platform", "bom-ref": ref, "name": engine["name"],
            "scope": "required", "description": engine["description"],
            "externalReferences": [{"type": "website", "url": engine["url"]}],
            "properties": property_list(platform=engine["platform"]),
        })
        link([plugin], ref)

    epoch = os.environ.get("SOURCE_DATE_EPOCH")
    timestamp = (datetime.datetime.fromtimestamp(int(epoch), datetime.timezone.utc)
                 if epoch else datetime.datetime.now(datetime.timezone.utc))

    bom = {
        "$schema": "http://cyclonedx.org/schema/bom-1.6.schema.json",
        "bomFormat": "CycloneDX",
        "specVersion": "1.6",
        "serialNumber": f"urn:uuid:{uuid.uuid4()}",
        "version": 1,
        "metadata": {
            "timestamp": timestamp.strftime("%Y-%m-%dT%H:%M:%SZ"),
            "tools": {"components": [{
                "type": "application",
                "name": "scripts/sbom.py",
                "externalReferences": [{"type": "vcs", "url": APP["vcs"]}],
            }]},
            "component": {
                "type": "application",
                "bom-ref": app_ref,
                "name": APP["name"],
                "version": app_version,
                "description": APP["description"],
                "publisher": APP["publisher"],
                "licenses": [{"license": {"id": APP["license"]}}],
                "externalReferences": [{"type": "vcs", "url": APP["vcs"]}],
            },
        },
        "components": components,
        "dependencies": [
            {"ref": ref, "dependsOn": sorted(refs)}
            for ref, refs in sorted(depends_on.items())
        ],
    }

    text = json.dumps(bom, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        Path(args.output).write_text(text, encoding="utf-8")
        print(f"{len(components)} components → {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(text)


if __name__ == "__main__":
    main()
