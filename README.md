
## FVMバージョン合わせ
% fvm releases
% fvm list
% fvm install 3.24.2
インストール先は~/fvm/versions
% fvm remove 2.10.4
% cd ~/pc_data/project/scal
% fvm use 3.24.2


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

# iOS
### CocoaPods
sudo gem install -n /usr/local/bin -v 1.15.2 cocoapods
sudo gem uninstall cocoapods

# Firebase
### Firebase CLI
% curl -sL https://firebase.tools | bash

### ログイン
% firebase login
〜
? Allow Firebase to collect CLI and Emulator Suite usage and error reporting information? Yes
〜
✔  Success! Logged in as wakizaka24@gmail.com

### FlutterFire CLI
% fvm dart pub global activate flutterfire_cli

### Firebase Coreをプロジェクトに適用する
% cd ~/pc\_data/project/scal
% fvm flutter pub add firebase_core

### プロジェクトにFirebaseを適用/初期化する
% sudo fvm dart pub global run flutterfire_cli:flutterfire configure

### Firebaseサービスを追加する
% fvm flutter pub add firebase_crashlytics
% fvm flutter pub add firebase_analytics
? You have an existing `firebase.json` file and possibly already configured your project for Firebase. Would you prefer to reuse the values in your existing `firebase.jso✔ You have an existing `firebase.json` file and possibly already configured your project for Firebase. Would you prefer to reuse the values in your existing `firebase.json` file to configure your project? · yes
% sudo fvm dart pub global run flutterfire_cli:flutterfire configure

# dSYM(iOSのデバッグシンボル)

### dSYMの場所
ローカル実行
% fvm flutter build ios
build/ios/Release-iphoneos/Runner.app.dSYM

Archive
~/Library/Developer/Xcode/Archives/2024-09-21/Runner\ 2024-09-21\,\ 15.58.xcarchive/dSYMs

### iOSのdSYMの自動アップロード
1.iOSのプロジェクトのTARGETSを選択し、+からNew Run Script Phaseでスクリプトを増やしスクリプトを2つ追加する。
Firebase Crashlyticsを実行するスクリプト
#!/bin/bash
${PODS_ROOT}/FirebaseCrashlytics/run
dSYMをアップロードするスクリプト
#!/bin/bash
${PODS_ROOT}/FirebaseCrashlytics/upload-symbols -gsp ${PROJECT_DIR}/Runner/GoogleService-Info.plist -p ios ${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}
2.iOSのプロジェクトのTARGETS、Build settingsを選択し、
Debug information formatをDWARF with dSYM fileにする。