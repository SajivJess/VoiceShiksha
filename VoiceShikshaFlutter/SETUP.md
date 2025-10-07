# Flutter Development Environment Setup

## Prerequisites
- Flutter SDK: `H:\Requirements\FlutterSDK\flutter\bin`
- Android Studio SDK: `H:\Requirements\AndroidstudioSDk`

## Environment Setup

### 1. Add Flutter to PATH

Add the following to your system PATH environment variable:
```
H:\Requirements\FlutterSDK\flutter\bin
```

### 2. Set ANDROID_HOME Environment Variable

Set the following environment variable:
```
ANDROID_HOME=H:\Requirements\AndroidstudioSDk
```

### 3. Add Android SDK Tools to PATH

Add these to your system PATH:
```
H:\Requirements\AndroidstudioSDk\platform-tools
H:\Requirements\AndroidstudioSDk\cmdline-tools\latest\bin
H:\Requirements\AndroidstudioSDk\emulator
```

## PowerShell Setup Commands

Run these commands in PowerShell as Administrator:

```powershell
# Set Flutter Path
$env:PATH += ";H:\Requirements\FlutterSDK\flutter\bin"

# Set Android Home
$env:ANDROID_HOME = "H:\Requirements\AndroidstudioSDk"

# Add Android tools to PATH
$env:PATH += ";H:\Requirements\AndroidstudioSDk\platform-tools"
$env:PATH += ";H:\Requirements\AndroidstudioSDk\cmdline-tools\latest\bin"
$env:PATH += ";H:\Requirements\AndroidstudioSDk\emulator"

# Make changes permanent (requires restart)
[Environment]::SetEnvironmentVariable("PATH", $env:PATH, [EnvironmentVariableTarget]::Machine)
[Environment]::SetEnvironmentVariable("ANDROID_HOME", $env:ANDROID_HOME, [EnvironmentVariableTarget]::Machine)
```

## Verification Commands

After setup, verify your installation:

```bash
# Check Flutter installation
flutter doctor

# Check Flutter version
flutter --version

# Check Android SDK
flutter doctor --android-licenses

# List available devices
flutter devices
```

## Project Setup

1. Navigate to the Flutter project:
```bash
cd "f:\Projects\VoiceShiksha-main\VoiceShikshaFlutter"
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Troubleshooting

### Common Issues:

1. **Flutter not found**: Ensure `H:\Requirements\FlutterSDK\flutter\bin` is in PATH
2. **Android SDK issues**: Verify ANDROID_HOME points to `H:\Requirements\AndroidstudioSDk`
3. **License issues**: Run `flutter doctor --android-licenses` and accept all licenses
4. **No devices**: Start an Android emulator or connect a physical device

### Doctor Issues:

If `flutter doctor` shows issues:
- ✗ Android toolchain: Check ANDROID_HOME and SDK paths
- ✗ VS Code: Install Flutter and Dart extensions
- ✗ Connected device: Start emulator or connect device