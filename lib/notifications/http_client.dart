// SPDX-FileCopyrightText: 2026 Romain Pelletant
// SPDX-License-Identifier: Apache-2.0

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

/// HTTP client for the YouTrack API.
///
/// Dart checks TLS certificates itself, against the system root certificates
/// only: unlike WebView2, browsers and macOS, it does not download the
/// intermediate certificates a server fails to send. Such servers load in the
/// web view but fail here with CERTIFICATE_VERIFY_FAILED ("unable to get local
/// issuer certificate"). On Windows, the certificates Dart rejects are checked
/// again by Windows, which downloads the missing intermediates.
http.Client createApiClient() {
  if (!Platform.isWindows) return http.Client();
  return IOClient(HttpClient()..badCertificateCallback = _verifiedByWindows);
}

/// Certificates Windows accepted, by host: the check can download
/// certificates, so it runs once per certificate and host.
final _accepted = <String>{};

bool _verifiedByWindows(X509Certificate certificate, String host, int port) {
  final key = '$host ${base64.encode(certificate.der)}';
  if (_accepted.contains(key)) return true;
  bool ok;
  try {
    ok = using((arena) => _verifyChain(certificate.der, host, arena));
  } catch (_) {
    ok = false;
  }
  if (ok) _accepted.add(key);
  return ok;
}

/// Builds the chain of [der] with Windows (fetching missing intermediates
/// from the certificate's AIA URLs) and checks it with the SSL policy: trusted
/// root, validity, server authentication usage and [host] name.
bool _verifyChain(List<int> der, String host, Arena arena) {
  final encoded = arena<Uint8>(der.length);
  encoded.asTypedList(der.length).setAll(0, der);
  final context = _certCreateCertificateContext(
    _x509AsnEncoding | _pkcs7AsnEncoding,
    encoded,
    der.length,
  );
  if (context == nullptr) return false;
  try {
    final usages = arena<Pointer<Utf8>>()
      ..value = _serverAuthUsage.toNativeUtf8(allocator: arena);
    final chainPara = arena<_CertChainPara>()
      ..ref.cbSize = sizeOf<_CertChainPara>()
      ..ref.cUsageIdentifier = 1
      ..ref.rgpszUsageIdentifier = usages;
    final chain = arena<Pointer<Void>>();
    if (_certGetCertificateChain(
          nullptr,
          context,
          nullptr,
          nullptr,
          chainPara,
          0,
          nullptr,
          chain,
        ) ==
        0) {
      return false;
    }
    try {
      final ssl = arena<_SslPolicyPara>()
        ..ref.cbSize = sizeOf<_SslPolicyPara>()
        ..ref.dwAuthType = _authTypeServer
        ..ref.pwszServerName = host.toNativeUtf16(allocator: arena);
      final policy = arena<_CertChainPolicyPara>()
        ..ref.cbSize = sizeOf<_CertChainPolicyPara>()
        ..ref.pvExtraPolicyPara = ssl;
      final status = arena<_CertChainPolicyStatus>()
        ..ref.cbSize = sizeOf<_CertChainPolicyStatus>();
      return _certVerifyCertificateChainPolicy(
                Pointer.fromAddress(_certChainPolicySsl),
                chain.value,
                policy,
                status,
              ) !=
              0 &&
          status.ref.dwError == 0;
    } finally {
      _certFreeCertificateChain(chain.value);
    }
  } finally {
    _certFreeCertificateContext(context);
  }
}

// ── crypt32.dll ──────────────────────────────────────────────────────────────

const _x509AsnEncoding = 0x00000001;
const _pkcs7AsnEncoding = 0x00010000;
const _certChainPolicySsl = 4; // CERT_CHAIN_POLICY_SSL
const _authTypeServer = 2; // AUTHTYPE_SERVER
const _serverAuthUsage = '1.3.6.1.5.5.7.3.1'; // szOID_PKIX_KP_SERVER_AUTH

/// CERT_CHAIN_PARA, with its CERT_USAGE_MATCH inlined.
final class _CertChainPara extends Struct {
  @Uint32()
  external int cbSize;
  @Uint32()
  external int dwType; // USAGE_MATCH_TYPE_AND
  @Uint32()
  external int cUsageIdentifier;
  external Pointer<Pointer<Utf8>> rgpszUsageIdentifier;
}

/// SSL_EXTRA_CERT_CHAIN_POLICY_PARA
final class _SslPolicyPara extends Struct {
  @Uint32()
  external int cbSize;
  @Uint32()
  external int dwAuthType;
  @Uint32()
  external int fdwChecks;
  external Pointer<Utf16> pwszServerName;
}

/// CERT_CHAIN_POLICY_PARA
final class _CertChainPolicyPara extends Struct {
  @Uint32()
  external int cbSize;
  @Uint32()
  external int dwFlags;
  external Pointer<_SslPolicyPara> pvExtraPolicyPara;
}

/// CERT_CHAIN_POLICY_STATUS
final class _CertChainPolicyStatus extends Struct {
  @Uint32()
  external int cbSize;
  @Uint32()
  external int dwError;
  @Int32()
  external int lChainIndex;
  @Int32()
  external int lElementIndex;
  external Pointer<Void> pvExtraPolicyStatus;
}

// Top-level finals are lazy: crypt32.dll is only loaded on Windows.
final _crypt32 = DynamicLibrary.open('crypt32.dll');

final _certCreateCertificateContext = _crypt32
    .lookupFunction<
      Pointer<Void> Function(Uint32, Pointer<Uint8>, Uint32),
      Pointer<Void> Function(int, Pointer<Uint8>, int)
    >('CertCreateCertificateContext');

final _certFreeCertificateContext = _crypt32
    .lookupFunction<Int32 Function(Pointer<Void>), int Function(Pointer<Void>)>(
      'CertFreeCertificateContext',
    );

final _certGetCertificateChain = _crypt32
    .lookupFunction<
      Int32 Function(
        Pointer<Void>,
        Pointer<Void>,
        Pointer<Void>,
        Pointer<Void>,
        Pointer<_CertChainPara>,
        Uint32,
        Pointer<Void>,
        Pointer<Pointer<Void>>,
      ),
      int Function(
        Pointer<Void>,
        Pointer<Void>,
        Pointer<Void>,
        Pointer<Void>,
        Pointer<_CertChainPara>,
        int,
        Pointer<Void>,
        Pointer<Pointer<Void>>,
      )
    >('CertGetCertificateChain');

final _certFreeCertificateChain = _crypt32
    .lookupFunction<Void Function(Pointer<Void>), void Function(Pointer<Void>)>(
      'CertFreeCertificateChain',
    );

final _certVerifyCertificateChainPolicy = _crypt32
    .lookupFunction<
      Int32 Function(
        Pointer<Void>,
        Pointer<Void>,
        Pointer<_CertChainPolicyPara>,
        Pointer<_CertChainPolicyStatus>,
      ),
      int Function(
        Pointer<Void>,
        Pointer<Void>,
        Pointer<_CertChainPolicyPara>,
        Pointer<_CertChainPolicyStatus>,
      )
    >('CertVerifyCertificateChainPolicy');
