; Inno Setup script of the Windows installer. Built by `scripts/release.sh windows`:
;   iscc /DAppVersion=<v> /DSourceDir=<flutter Release dir> /DOutputDir=<dir> utd.iss
;
; Per-user install by default (no admin rights needed); the wizard offers an
; all-users install. The MSVC runtime is in SourceDir (windows/CMakeLists.txt),
; so the Visual C++ Redistributable is not needed.

#ifndef AppVersion
  #error AppVersion is required
#endif
#ifndef SourceDir
  #error SourceDir is required
#endif
#ifndef OutputDir
  #define OutputDir "."
#endif

[Setup]
; Never change AppId: Windows uses it to find the installed version on upgrade.
AppId={{821C7ADE-C6A7-48BA-9458-D9948750EDDB}
AppName=UTD
AppVersion={#AppVersion}
AppVerName=UTD {#AppVersion}
AppPublisher=Romain Pelletant
AppPublisherURL=https://github.com/romainpelletant/utrack-desktop
DefaultDirName={autopf}\UTD
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0
OutputDir={#OutputDir}
OutputBaseFilename=UTD-{#AppVersion}-windows-x64-setup
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\UTD.exe
LicenseFile=..\..\LICENSE
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
CloseApplications=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[CustomMessages]
english.DiagnosticShortcut=UTD (diagnostic)
french.DiagnosticShortcut=UTD (diagnostic)

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]
; Stale Flutter assets from a previous version.
Type: filesandordirs; Name: "{app}\data"

[Icons]
Name: "{autoprograms}\UTD"; Filename: "{app}\UTD.exe"
; Logs every startup step to utd-diagnostic.log, for bug reports.
Name: "{autoprograms}\{cm:DiagnosticShortcut}"; Filename: "{app}\UTD.exe"; Parameters: "--diagnostic"
Name: "{autodesktop}\UTD"; Filename: "{app}\UTD.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\UTD.exe"; Description: "{cm:LaunchProgram,UTD}"; Flags: nowait postinstall skipifsilent
