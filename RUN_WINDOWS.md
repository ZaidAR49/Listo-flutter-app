# How to Run Flutter App on Windows

## Prerequisites
1. **Flutter SDK** - Install from https://flutter.dev/docs/get-started/install/windows
2. **Git** - Usually comes with Flutter installation
3. **Visual Studio** - Install from Microsoft with "Desktop development with C++" workload
   - Or install just the build tools: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022

## Steps to Run

### 1. Check Flutter Setup
Open Command Prompt or PowerShell in the project directory and run:
```bash
flutter doctor
```
Make sure you see checks (✓) for:
- Flutter (channel, version)
- Windows toolchain
- Visual Studio - for Windows

### 2. Enable Windows Desktop (if needed)
```bash
flutter config --enable-windows-desktop
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Create .env File (Optional)
The app uses a `.env` file for configuration. If you don't have one, create it in the root directory:
```
# .env file (optional - app will work without it using default values)
ANDROID_BANNER_AD_UNIT_ID=your_ad_unit_id_here
IOS_BANNER_AD_UNIT_ID=your_ad_unit_id_here
```
Note: The app will work without this file, but ads may not function properly.

### 5. Check Available Devices
```bash
flutter devices
```
You should see a Windows desktop entry.

### 6. Run the App
```bash
flutter run -d windows
```

Or if you only have Windows available:
```bash
flutter run
```

## Troubleshooting

### If you get "Windows desktop not enabled" error:
```bash
flutter config --enable-windows-desktop
flutter create --platforms=windows .
```

### If you get build errors:
1. Make sure Visual Studio is installed with C++ tools
2. Run `flutter clean`
3. Run `flutter pub get`
4. Try again: `flutter run -d windows`

### If .env file causes errors:
- The app should still run without it (it has fallback values)
- Create an empty `.env` file if needed

## Building for Release

To create a release build:
```bash
flutter build windows --release
```

The executable will be in: `build\windows\x64\runner\Release\my_app.exe`

