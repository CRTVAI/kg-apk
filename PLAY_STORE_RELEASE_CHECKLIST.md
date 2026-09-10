# Play Store Release Checklist

## 1. Confirm Play Console Access

- Open the existing app in Google Play Console.
- Confirm your account can create releases for the app.
- For a brand-new app listing, use the new package name `com.kgauto.app`.

## 2. Add The Client's Upload Key Locally

Create `android/key.properties` from `android/key.properties.example`.

For this new app listing, this file points to the new upload keystore:

```properties
storePassword=...
keyPassword=...
keyAlias=...
storeFile=C:/absolute/path/to/upload-keystore.jks
```

Do not commit or publicly share `android/key.properties`, `.jks`, or `.keystore` files. Keep a private backup for future app updates.

## 3. Bump The App Version

Update `pubspec.yaml` before every Play Console upload:

```yaml
version: 1.0.3+4
```

The number after `+` is the Android version code. It must always increase.

## 4. Build The Store File

Use an Android App Bundle for Google Play:

```powershell
$env:JAVA_HOME='C:\tmp\jdk17\jdk-17.0.19+10'
$env:Path="$env:JAVA_HOME\bin;$env:Path"
C:\tmp\flutter-3.13.9\flutter\bin\flutter.bat build appbundle --release
```

Upload this file:

```text
build/app/outputs/bundle/release/app-release.aab
```

## 5. Upload In Play Console

- Go to the app in Play Console.
- Choose the release track: Internal testing, Closed testing, or Production.
- Create a new release and upload the `.aab`.
- Add release notes.
- Resolve Play Console warnings and required app-content forms.
- Submit for review.
