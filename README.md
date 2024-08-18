
## FVMバージョン合わせ
% fvm releases
% fvm list
% fvm install 3.24.0
インストール先は~/fvm/versions
% fvm remove 2.10.4
% cd ~/pc_data/project/scal
% fvm use 3.24.0


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
android:label="Starlight"

% cd scal
% fvm flutter build appbundle --release