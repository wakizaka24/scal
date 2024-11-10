## FVMバージョン合わせ
% fvm releases
% fvm list
% fvm install 3.24.4
インストール先は~/fvm/versions
% fvm remove 2.10.4
% cd ~/pc_data/project
% fvm use 3.24.4

## FVMプロジェクト作成(FVMバージョン合わせの後)
% fvm flutter create ./scal --project-name scal --platforms android,ios,web --org com.wakizaka

## Android/iOS共通
### ライブラリ更新前
% fvm flutter clean

## Android
### wakizaka24-keystore.jksファイル作成
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

### リリース設定
% cd ~/pc\_data/project/scal
% cp /Users/ryota24/wakizaka24-keystore.jks ./android

% cd ~/pc\_data/project/scal
% vi ./android/key.properties
storePassword=first-app-24
keyPassword=first-app-24
keyAlias=key
storeFile=/Users/ryota24/wakizaka24-keystore.jks

% cd ~/pc\_data/project/scal
% vi ./android/app/src/main/AndroidManifest.xml
<application
android:label="Starlight"

### app-release.aabファイル作成
% cd ~/pc\_data/project/scal
% fvm flutter build appbundle --release

### Application IDを変更する(com.wakizaka24.scal.v3に変更)
% fvm flutter pub run change_app_package_name:main com.wakizaka24.scal.v3

## iOS
### CocoaPods
% sudo gem install -n /usr/local/bin -v 1.15.2 cocoapods
% sudo gem uninstall cocoapods

### リリース設定
% cd ~/pc\_data/project/scal
% vi ./ios/Runner/Info.plist
<key>CFBundleName</key>
<string>scal</string>

### Archive前のアプリ更新
% cd ~/pc\_data/project/scal
% fvm flutter build ios

## Web(ベータ版)
### デプロイ
% cd ~/pc\_data/project/scal
% sh deploy_sakura.sh

## アプリアイコン設定
% cd ~/pc\_data/project/scal
% vi pubspec.yaml
flutter_launcher_icons:
ios: true
image_path: "images/ios_app_icon_starlight.png"
android: true
adaptive_icon_background: "images/launcher/icon_adaptive_background.png"
adaptive_icon_foreground: "images/launcher/icon_adaptive_foreground.png"

% fvm dart run flutter_launcher_icons:main

## Firebase
### Firebase CLI
% cd ~/pc\_data/project/scal
% curl -sL https://firebase.tools | bash

### ログイン
% cd ~/pc\_data/project/scal
% firebase login
〜
? Allow Firebase to collect CLI and Emulator Suite usage and error reporting information? Yes
〜
✔  Success! Logged in as wakizaka24@gmail.com

### FlutterFire CLI
% cd ~/pc\_data/project/scal
% fvm dart pub global activate flutterfire_cli

### Firebase Coreをプロジェクトに適用する
% cd ~/pc\_data/project/scal
% fvm flutter pub add firebase_core

### プロジェクトにFirebaseを適用/初期化する
% cd ~/pc\_data/project/scal
% sudo fvm dart pub global run flutterfire_cli:flutterfire configure

### Firebaseサービスを追加する
% cd ~/pc\_data/project/scal
% fvm flutter pub add firebase_crashlytics
% fvm flutter pub add firebase_analytics
? You have an existing `firebase.json` file and possibly already configured your project for Firebase. Would you prefer to reuse the values in your existing `firebase.jso✔ You have an existing `firebase.json` file and possibly already configured your project for Firebase. Would you prefer to reuse the values in your existing `firebase.json` file to configure your project? · yes
% sudo fvm dart pub global run flutterfire_cli:flutterfire configure

## dSYM(iOSのデバッグシンボル)
### dSYMの場所
ローカル実行(Zipに圧縮してアップロード)
/Users/ryota24/pc_data/project/scal/build/ios/Debug-iphonesimulator/Runner.app.dSYM
Archive(Zipに圧縮してアップロード)
~/Library/Developer/Xcode/Archives/2024-09-21/Runner\ 2024-09-21\,\ 15.58.xcarchive/dSYMs

### iOSのdSYMの自動アップロード
iOSのプロジェクトのTARGETSを選択し、+からNew Run Script PhaseでスクリプトとInput Filesを追加する。
Firebase Crashlyticsを実行するスクリプト
#!/bin/bash
$PODS_ROOT/FirebaseCrashlytics/run
iOSのdSYMの自動アップロードするスクリプト1
#!/bin/bash
$PODS_ROOT/FirebaseCrashlytics/upload-symbols --build-phase --validate -ai "1:1058866964717:ios:90aa21e9065b20eb84c4e4" -- $DWARF_DSYM_FOLDER_PATH/App.framework.dSYM
Input Filesを追加する
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist
$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist
$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)
iOSのdSYMの自動アップロードするスクリプト2
#!/bin/bash
$PODS_ROOT/FirebaseCrashlytics/upload-symbols --build-phase -ai "1:1058866964717:ios:90aa21e9065b20eb84c4e4" --
Input Filesを追加する
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Resources/DWARF/${PRODUCT_NAME}
${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}/Contents/Info.plist
$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/GoogleService-Info.plist
$(TARGET_BUILD_DIR)/$(EXECUTABLE_PATH)