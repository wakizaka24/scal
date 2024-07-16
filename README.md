
## Android
### app-release.aabファイル作成
% keytool -genkey -v -keystore ~/wakizaka24-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
first-app-24
first-app-24
Ryota Wakizaka
Personal development
Ryota Wakizaka
Katsushika ward
Tokyo
JP
y

% cd scal
% cp /Users/ryota24/wakizaka24-keystore.jks ./android

% cd scal
% vi ./android/key.properties
storePassword=first-app-24
keyPassword=first-app-24
keyAlias=key
storeFile=/Users/ryota24/wakizaka24-keystore.jks

% cd scal
% vi ./android/app/src/main/AndroidManifest.xml
<application
android:label="FlickCalender"

% cd scal
% fvm flutter build appbundle --release