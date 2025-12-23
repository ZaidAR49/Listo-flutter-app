# Logo Setup Instructions

## Step 1: Replace the Logo File

1. Save the new logo image as `assets/logo.png`
   - The image should be a PNG file
   - Recommended size: 1024x1024 pixels (square) for best quality
   - The image will be automatically resized for different platforms

2. Replace the existing `assets/logo.png` file with your new logo

## Step 2: Regenerate Application Icons

After replacing the logo file, run these commands to regenerate all platform icons:

### For Windows:
```bash
flutter pub run flutter_launcher_icons
```

### Or use the full command:
```bash
dart run flutter_launcher_icons
```

This will:
- Generate Windows icon (.ico file) in `windows/runner/resources/app_icon.ico`
- Generate Android launcher icons in various sizes
- Generate iOS app icons
- Update all platform-specific icon files

## Step 3: Verify the Logo in the App

The logo is displayed in:
- **AppBar** (top of home screen)
- **Drawer** (side menu)
- **About Page**

All these locations will automatically use the new `assets/logo.png` file.

## Step 4: Rebuild the Application

After updating the icons, rebuild your application:

### Windows:
```bash
flutter build windows
```

### Android:
```bash
flutter build apk
# or
flutter build appbundle
```

## Notes:

- The logo in the app (AppBar, Drawer, About page) will update immediately when you replace `assets/logo.png`
- Application icons (desktop shortcuts, app launcher) require regenerating icons and rebuilding
- For best results, use a square PNG image (1024x1024 or larger)
- The logo will be automatically resized and optimized for each platform

