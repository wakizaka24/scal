## Homebrewをインストール(FVMインストールで使用)
% /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
% vi ~/.zshrc
export PATH=$PATH:/opt/homebrew/bin
% source ~/.zshrc

## FVMインストール
% brew tap leoafarias/fvm
% brew install fvm

{
## FVMアンインストール
% brew uninstall fvm
% brew untap leoafarias/fvm
}

## FVMバージョン合わせ(更新1)
Android SDKはFlutter SDKのデフォルトを使用しているが、
最新版のSDKを使いたい場合は、直接指定する必要がある
android/app/build.gradle
targetSdkVersion flutter.targetSdkVersion
targetSdkVersion 35

% fvm releases --all
% fvm list
% fvm install 3.32.8
インストール先は~/fvm/versions
% fvm remove 2.10.4
% cd ~/pc_data/project
% fvm use 3.32.8

## Flutterバージョンが使用するGradleのJavaバージョンにPCを合わせる
バージョンが合わない時のエラーメッセージ
「Unsupported class file major version 65」
1. Gradleのバージョンの確認
cat scal/android/gradle/wrapper/gradle-wrapper.properties
「distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip」
2. Javaのバージョンの確認
% Java --version
java 11.0.22 2024-01-16 LTS
→ gradle7.5のJavaバージョンはJava18なのでJava18をインストールする。
3. Javaのインストール
https://www.oracle.com/java/technologies/javase/jdk18-archive-downloads.html
「macOS 64 DMG Installer」
インストール先の確認。アンインストールはフォルダごと削除で良い。
% ls -al /Library/Java/JavaVirtualMachines/
% sudo rm -rf /Library/Java/JavaVirtualMachines/jdk-17.jdk
4. 使用するJavaを変更する
% /usr/libexec/java_home -V
18.0.2.1 (arm64) "Oracle Corporation" - "Java SE 18.0.2.1" /Library/Java/JavaVirtualMachines/jdk-18.0.2.1.jdk/Contents/Home
11.0.22 (arm64) "Oracle Corporation" - "Java SE 11.0.22" /Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home
% fvm flutter config --jdk-dir="/Library/Java/JavaVirtualMachines/jdk-18.0.2.1.jdk/Contents/Home"

## FVMプロジェクト作成(FVMバージョン合わせの後)
% fvm flutter create ./scal --project-name scal --platforms android,ios,web --org com.wakizaka

## Flutterの環境構築
### Android(更新2 Androidのビルド環境最新にする時も必要)
1. Google Developerサイト(https://developer.android.com/studio?hl=ja)から開発対象のAndroid Studioをインストールする。
2. Android SDK Command-line Toolsをインストールする(ここは初回だけ)。
Preferences > SDK Manager > System Settings > Android SDK > SDK Tools > Android SDK Command-line Toolsのチェックを入れる
3. ライセンスを許諾する。
% fvm flutter doctor --android-licenses
### iOS(更新3 iOSのビルド環境最新にする時も必要)
1. App StoreでXcodeをインストールする。
(Xcodeの標準の名前でアプリがないとgemでCocoaPodsをインストールできないため)
2. Apple Developerサイト(https://developer.apple.com/download/all/)から開発対象のXcodeをインストールし、リネームしてアプリケーションフォルダに入れる。
例) Xcode_16.4.app
3. CocoaPodsをインストールする。
% sudo gem install -n /usr/local/bin -v 1.16.2 cocoapods
{
4. CocoaPodsをアンインストールする。
% sudo gem uninstall cocoapods
}
5. Flutterの使用するXcodeの設定
% sudo xcode-select --switch "/Applications/Xcode_16.4.app/Contents/Developer"
% sudo xcodebuild -runFirstLaunch
% [Enter]
% agree[Enter]
% open -a Simulator

### FVMの環境パスを設定する
% vi ~/.zshrc
export PATH=$PATH:$HOME/.pub-cache/bin
export PATH=~/fvm/default/bin:$PATH
% source ~/.zshrc

### Flutterの設定診断
% fvm flutter doctor -v

## Android/iOS共通
### ライブラリ更新前
% fvm flutter clean

## Androidのリリース時
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

## iOSのリリース時
### リリース設定
% cd ~/pc\_data/project/scal
% vi ./ios/Runner/Info.plist
<key>CFBundleName</key>
<string>scal</string>

### Archive前のアプリ更新
% cd ~/pc\_data/project/scal
% fvm flutter build ios

## Web(ベータ版)のリリース時
### デプロイ
vi pubspec.yaml
intl: ^0.20.2

% cd ~/pc\_data/project/scal
% sh deploy_sakura.sh

## iOS/Androidのアプリアイコン設定
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

## Flutter(iOS/Android)の更新処理
1.前記の更新1〜更新3を再度行う
2.AGPを更新する(Android)
vi scal/android/settings.gradle
plugins {
id "com.android.application" version "8.12.0" apply false
3.Gradleを更新する(Android)
vi scal/android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-bin.zip
4.ライブラリを更新する(Android)
/Users/ryota24/pc_data/project/scal/pubspec.yaml
5.Androidリリースファイル作成時のエラーから、AGP8.4以降の圧縮で、圧縮ファイルを追加する(Android)
vi scal/android/app/proguard-rules.pro