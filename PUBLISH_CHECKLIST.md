# Checklist: Preparing LISTO App for Google Play Store Publication

## ⚠️ CRITICAL CHANGES REQUIRED BEFORE PUBLISHING

### 1. **Change Package Name / Application ID** (REQUIRED)
**Location:** `android/app/build.gradle.kts`

**Current:** `com.example.my_app` (This is a placeholder and CANNOT be used)

**Action Required:**
- Change `applicationId = "com.example.my_app"` to your unique package name
- Format: `com.yourname.listo` or `com.yourcompany.listo`
- Example: `com.zaidradaideh.listo`
- **Note:** Once published, you CANNOT change this package name!

**Files to update:**
1. `android/app/build.gradle.kts` - Line 25: `applicationId = "com.example.my_app"`
2. `android/app/build.gradle.kts` - Line 9: `namespace = "com.example.my_app"`
3. `android/app/src/main/kotlin/com/example/my_app/MainActivity.kt` - Move/rename folder structure

**Steps:**
- Change `namespace` and `applicationId` in `build.gradle.kts`
- Move folder: `android/app/src/main/kotlin/com/example/my_app/` 
  - To: `android/app/src/main/kotlin/com/yourname/listo/`
- Update package declaration in `MainActivity.kt`

---

### 2. **Set Up App Signing** (REQUIRED)

**Current:** Using debug signing (line 38 in build.gradle.kts)

**Action Required:**

**Option A: Google Play App Signing (Recommended)**
- Google will manage your signing key
- Generate upload keystore:
  ```bash
  keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
  ```
- Store the password securely!
- Create `android/key.properties` file:
  ```
  storePassword=your_store_password
  keyPassword=your_key_password
  keyAlias=upload
  storeFile=../upload-keystore.jks
  ```
- Update `android/app/build.gradle.kts` to use this keystore

**Option B: Manual Signing**
- Generate release keystore as above
- Keep backup of keystore file in secure location
- Update `build.gradle.kts` to reference keystore

---

### 3. **Update App Description** (RECOMMENDED)

**Location:** `pubspec.yaml`

**Current:** `description: "A new Flutter project."`

**Action Required:**
- Change to: `description: "LISTO - A simple memory keeping app to organize your thoughts."`
- This description appears in the Play Store listing

---

### 4. **Verify App Version**

**Location:** `pubspec.yaml` - Line 19

**Current:** `version: 1.0.1+2`
- Format: `version: <version_name>+<version_code>`
- `1.0.1` = Version name (shown to users)
- `2` = Version code (must increment with each upload)
- **This looks good for first release!**

---

### 5. **Verify App Name**

**Location:** `android/app/src/main/AndroidManifest.xml` - Line 10

**Current:** `android:label="LISTO"` ✅ **Already correct!**

---

### 6. **AdMob Configuration** (If using ads)

**Location:** `android/app/src/main/AndroidManifest.xml` - Line 44

**Current:** `android:value="ca-app-pub-2401001147258109~8974060126"`

**Action Required:**
- Verify this is YOUR actual AdMob App ID
- If this is a test ID, replace with your production App ID
- Make sure you have the corresponding ad unit IDs in your `.env` file

---

### 7. **Update .env File for Production** (If using)

**Location:** Root directory `.env`

**Action Required:**
- Replace test ad unit IDs with production IDs
- Ensure `.env` file exists in root directory
- Note: `.env` should NOT be committed to git (check `.gitignore`)

---

### 8. **Update Package Name in Kotlin Files**

**Location:** `android/app/src/main/kotlin/com/example/my_app/MainActivity.kt`

**Action Required:**
- Change package declaration from `package com.example.my_app`
- To: `package com.yourname.listo` (match your new applicationId)
- Move the file to the new folder structure if needed

---

### 9. **Update Build Configuration for Release**

**Location:** `android/app/build.gradle.kts` - Lines 34-40

**Current:** Using debug signing for release builds

**Action Required:**
- Configure release signing with your keystore
- Enable ProGuard/R8 for code obfuscation (optional but recommended)
- Remove debug-only code if any

---

### 10. **Test Release Build**

**Action Required:**
- Build release APK: `flutter build apk --release`
- Build App Bundle: `flutter build appbundle` (required for Play Store)
- Test the release build thoroughly on real devices
- Check all features work correctly
- Verify ads work (if applicable)
- Test notifications
- Test image picker permissions

---

## 📋 ADDITIONAL REQUIREMENTS FOR GOOGLE PLAY CONSOLE

### Before Uploading:

1. **Create Google Play Developer Account**
   - One-time $25 registration fee
   - Visit: https://play.google.com/console

2. **Prepare Store Listing Assets:**
   - App icon (512x512 PNG)
   - Feature graphic (1024x500 PNG)
   - Screenshots (at least 2, up to 8)
   - Short description (80 characters max)
   - Full description (4000 characters max)
   - Privacy Policy URL (REQUIRED if app handles user data)

3. **Content Rating:**
   - Complete content rating questionnaire
   - Get rating certificate

4. **Target Audience:**
   - Set age group
   - Declare data collection practices

5. **Pricing & Distribution:**
   - Set as free or paid
   - Choose countries for distribution

---

## 🔍 CODE REVIEW CHECKLIST

Before publishing, verify:

- [ ] Package name changed from `com.example.my_app`
- [ ] App signing configured properly
- [ ] Version code increments with each release
- [ ] App name is correct ("LISTO")
- [ ] All TODOs in code are addressed or removed
- [ ] No debug/test code left in release build
- [ ] Privacy Policy link added (if collecting data)
- [ ] Permissions are justified and declared
- [ ] App works without internet (if it should)
- [ ] Error handling is robust
- [ ] App doesn't crash on startup
- [ ] All features tested on release build

---

## 🚀 BUILD COMMANDS

```bash
# Build release APK (for testing)
flutter build apk --release

# Build App Bundle (REQUIRED for Play Store upload)
flutter build appbundle

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

---

## 📝 IMPORTANT NOTES

1. **Package Name:** Cannot be changed after first publication. Choose carefully!

2. **Signing Key:** Keep backup of keystore file. If lost, you cannot update your app!

3. **Version Code:** Must always increase with each upload (currently at 2)

4. **Privacy Policy:** Required if your app:
   - Collects any user data
   - Uses ads (AdMob)
   - Accesses device storage/images

5. **Testing:** Use Internal Testing track first before Production release

6. **Review Time:** First app review can take 1-7 days

---

## 🔗 HELPFUL LINKS

- [Flutter Release Documentation](https://docs.flutter.dev/deployment/android)
- [Google Play Console](https://play.google.com/console)
- [App Signing Guide](https://docs.flutter.dev/deployment/android#signing-the-app)
- [Play Store Requirements](https://support.google.com/googleplay/android-developer/answer/9888170)

