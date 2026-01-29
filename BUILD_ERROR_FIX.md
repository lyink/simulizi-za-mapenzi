# Build Error Fix - Network Connection Issues

## ⚠️ Current Error

Your build is failing due to network connectivity issues when Gradle tries to download dependencies:

```
Could not GET 'https://dl.google.com/...'
Could not GET 'https://repo.maven.apache.org/...'
Connection timed out: getsockopt
```

## 🔍 Root Cause

The build system cannot reach:
- `dl.google.com` (Google Maven Repository)
- `repo.maven.apache.org` (Maven Central Repository)

This is typically caused by:
1. Network connectivity issues
2. Firewall blocking connections
3. VPN or proxy interference
4. DNS resolution problems

## ✅ Solutions (Try in Order)

### Solution 1: Check Internet Connection

1. Verify you have stable internet
2. Try opening these URLs in browser:
   - https://dl.google.com
   - https://repo.maven.apache.org
3. If they don't load, you have a network issue

### Solution 2: Configure Proxy (If Using VPN/Corporate Network)

Create/edit `android/gradle.properties`:

```properties
# If you're behind a proxy
systemProp.http.proxyHost=your.proxy.host
systemProp.http.proxyPort=8080
systemProp.https.proxyHost=your.proxy.host
systemProp.https.proxyPort=8080

# If proxy requires authentication
systemProp.http.proxyUser=username
systemProp.http.proxyPassword=password
systemProp.https.proxyUser=username
systemProp.https.proxyPassword=password
```

### Solution 3: Use Alternative Mirrors

Edit `android/build.gradle.kts` and add mirrors:

```kotlin
buildscript {
    repositories {
        // Add mirrors first
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/jcenter") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }

        // Then original repos
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        // Add mirrors first
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/jcenter") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }

        // Then original repos
        google()
        mavenCentral()
    }
}
```

### Solution 4: Clear Gradle Cache

Run these commands:

```bash
# Windows
cd android
.\gradlew clean
cd ..

# Clear Flutter build cache
flutter clean

# Re-download dependencies
flutter pub get

# Try building again
flutter run
```

### Solution 5: Offline Mode (If Dependencies Already Downloaded)

Edit `android/gradle.properties`:

```properties
org.gradle.offline=true
```

⚠️ **Warning**: Only use if dependencies are already cached.

### Solution 6: Increase Timeout

Edit `android/gradle.properties`:

```properties
# Increase timeout (in milliseconds)
systemProp.org.gradle.internal.http.connectionTimeout=120000
systemProp.org.gradle.internal.http.socketTimeout=120000
```

### Solution 7: Use Different DNS

Try changing your DNS to:
- **Google DNS**: 8.8.8.8, 8.8.4.4
- **Cloudflare DNS**: 1.1.1.1, 1.0.0.1

#### Windows:
1. Open Network Settings
2. Change adapter options
3. Right-click your network → Properties
4. Select IPv4 → Properties
5. Use the DNS servers above

### Solution 8: Disable IPv6

Sometimes IPv6 causes connection issues:

#### Windows:
1. Open Network Settings
2. Change adapter options
3. Right-click your network → Properties
4. Uncheck "Internet Protocol Version 6 (TCP/IPv6)"

## 🚀 Quick Fix (Most Common)

**For most users in areas with connectivity issues:**

1. Edit `android/build.gradle.kts`:

```kotlin
buildscript {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        google()
        mavenCentral()
    }
}
```

2. Run:
```bash
flutter clean
flutter pub get
flutter run
```

## 🔍 Verify Fix

After trying a solution:

```bash
# Test Gradle connection
cd android
.\gradlew tasks

# If successful, build Flutter app
cd ..
flutter run
```

## 📱 Alternative: Build Without Native Splash

If `flutter_native_splash` keeps failing:

1. Remove from `pubspec.yaml`:
```yaml
# Comment out or remove
# flutter_native_splash: ^2.4.3
```

2. Run:
```bash
flutter pub get
flutter run
```

## 🌐 Check Your Network

Test these URLs in your browser:
- ✅ https://dl.google.com - Should show XML
- ✅ https://repo.maven.apache.org - Should load
- ✅ https://maven.aliyun.com - Should load

If any fail, you have a network/firewall issue.

## 💡 Common Scenarios

### Corporate/Office Network
- Use Solution 2 (Proxy Configuration)
- Contact IT for proxy details

### Home Network with VPN
- Try disconnecting VPN
- Or use Solution 2 with VPN proxy settings

### Mobile Hotspot
- Sometimes more stable than WiFi
- Try switching networks

### Poor Internet
- Use Solution 3 (Alternative Mirrors)
- These mirrors may be faster in your region

## ⚠️ Important Notes

- The error mentions `flutter_native_splash` specifically
- This is a splash screen plugin
- You can temporarily remove it to test if build works
- Add it back later when network is stable

## 🎯 Recommended Steps

1. Try Solution 3 (Alternative Mirrors) - **Fastest for most users**
2. If that fails, try Solution 4 (Clean & Rebuild)
3. If still failing, try Solution 2 (Proxy) or Solution 7 (DNS)
4. As last resort, remove `flutter_native_splash` temporarily

## ✅ Success Indicators

You'll know it's fixed when you see:
```
✓ Built build\app\outputs\flutter-apk\app-debug.apk
Launching lib\main.dart on sdk gphone64 x86 64 in debug mode...
```

Instead of:
```
FAILURE: Build failed with an exception
Connection timed out: getsockopt
```
