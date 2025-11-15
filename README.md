## Homebrewをインストール(FVMインストールで使用)
% /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
% vi ~/.zshrc
\# Brewコマンド
export PATH="/opt/homebrew/bin:$PATH"
% source ~/.zshrc

## FVMインストール
% brew tap leoafarias/fvm
% brew install fvm

{
## FVMアンインストール
% brew uninstall fvm
% brew untap leoafarias/fvm
}

### FVMの環境パスを設定する
% vi ~/.zshrc
\# FVM変更パス
export FVM_CACHE_PATH="$HOME/fvm"
\# FVMのデフォルトのパス
export PATH="$FVM_CACHE_PATH/default/bin:$PATH"
\# FVMコマンド
export PATH="$PATH:$HOME/.pub-cache/bin"
% source ~/.zshrc

## FVMバージョン合わせ(更新1)
Android SDKはFlutter SDKのデフォルトを使用している
直接指定する場合は値を変更する必要がある(普通はやらない)
android/app/build.gradle
compileSdkVersion flutter.compileSdkVersion
ndkVersion flutter.ndkVersion
compileSdkVersion 35 
ndkVersion "27.0.12077973"

% fvm releases --channel all
% fvm list
% fvm install 3.38.1
インストール先は~/fvm/versions
% fvm remove 3.35.7
% cd ~/pc_data/project/scal
% fvm global 3.38.1

## FlutterのAndroid Studioへの設定
Android Studio > Settings... > Languages & Frameworks > Flutter SDK path
/Users/ryota24/fvm/default
OKボタンを押す。

## Flutterバージョンが使用するGradleのJavaバージョンにPCを合わせる
バージョンが合わない時のエラーメッセージ
「Unsupported class file major version 65」
1. Gradleのバージョンの確認
% cd ~/pc_data/project/scal
% cat ./android/gradle/wrapper/gradle-wrapper.properties
「distributionUrl=https\://services.gradle.org/distributions/gradle-9.2.0-bin.zip」
2. Javaのバージョンの確認
% Java --version
openjdk 25.0.1 2025-10-21 LTS
OpenJDK Runtime Environment Temurin-25.0.1+8 (build 25.0.1+8-LTS)
OpenJDK 64-Bit Server VM Temurin-25.0.1+8 (build 25.0.1+8-LTS, mixed mode, sharing)
→ gradle8.13のJavaバージョンはJava17以上なのでJava17をインストールする。
3. Javaのインストール
% brew install --cask temurin
4. 使用するJavaを変更する
% /usr/libexec/java_home -V
Matching Java Virtual Machines (1):
   25.0.1 (arm64) "Eclipse Adoptium" - "OpenJDK 25.0.1" /Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home
   /Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home
% fvm flutter config --jdk-dir="/Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home"

## FVMプロジェクト作成(FVMバージョン合わせの後)
% fvm flutter create ./scal --project-name scal --platforms android,ios,web --org com.wakizaka

## Flutterの環境構築
### Android(更新2 Androidのビルド環境最新にする時も必要)
1. Google Developerサイト(https://developer.android.com/studio?hl=ja)から開発対象のAndroid Studioをインストールする。
2. Android SDK Command-line Toolsをインストールする(ここは初回)。
Tools > SDK Manager > Language & Frameworks > Android SDK > SDK Tools > Android SDK Command-line Toolsのチェックを入れる
3. ライセンスを許諾する。
% fvm flutter doctor --android-licenses
4. Android SDK Platform-Toolsの更新(初回以降の更新)。
Tools > SDK Manager > Language & Frameworks > Android SDK > SDK Tools > Android SDK Platform-Toolsにチェックして最新に更新する
### iOS(更新3 iOSのビルド環境最新にする時も必要)
1. App StoreでXcodeをインストールする。
(Xcodeの標準の名前でアプリがないとgemでCocoaPodsをインストールできないため)
2. Apple Developerサイト(https://developer.apple.com/download/all/)から開発対象のXcodeをインストールし、リネームしてアプリケーションフォルダに入れる。
例) Xcode_16.4.app
3. CocoaPodsをインストールする。
% sudo gem install -n /usr/local/bin -v 1.16.2 cocoapods
4. Rubyのバージョンが古い場合エラーが出るので、Rubyをインストールする。
ERROR:  Error installing cocoapods:
The last version of securerandom (>= 0.3) to support your Ruby & RubyGems was 0.3.2. Try installing it with `gem install securerandom -v 0.3.2` and then running the current command again
securerandom requires Ruby version >= 3.1.0. The current ruby version is 2.6.10.210.
% brew install ruby
% vi ~/.zshrc
\# Ruby(CocoaPodに使用)
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
% source ~/.zshrc
% which ruby
% ruby --version
5. CocoaPodsをアンインストール(削除したい場合)
% sudo gem uninstall cocoapods
6. Flutterの使用するXcodeの設定
% sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
% sudo xcodebuild -runFirstLaunch
% [Enter]
% agree[Enter]
% open -a Simulator

### iOSのライブラリを更新する。
% cd ./ios
% pod repo update
% rm Podfile.lock
% pod install --repo-update

### Flutterの設定診断
% fvm flutter doctor -v

## Android/iOS共通
### ライブラリ更新前
% fvm flutter clean

## リリースと同じ状態で実行
% fvm flutter run --release

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

### プロビジョニングプロファイルの作成に必要なCSRの作成
キーチェーンアクセス > 証明書アシスタント > 認証局に証明書を要求 
メールアドレス + 名前（任意） > 「ディスクに保存」 > 作成

### Archive前のアプリ更新
% cd ~/pc\_data/project/scal
% fvm flutter build ios

## Web(ベータ版)のリリース時
### デプロイ
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

### Rosetta2 インストール
% softwareupdate --install-rosetta --agree-to-license

### Node インストール
% brew install node

### Firebase CLI インストール
% npm install -g firebase-tools@latest

### Firebase ログイン
% firebase login
i  The Firebase CLI’s MCP server feature can optionally make use of Gemini in Firebase. Learn more about Gemini in Firebase and how it uses your data: https://firebase.google.com/docs/gemini-in-firebase#how-gemini-in-firebase-uses-your-data
? Enable Gemini in Firebase features? (Y/n)
n コード生成などのAI機能使用しない
i  Firebase optionally collects CLI and Emulator Suite usage and error reporting information to help improve our products. Data is collected in accordance with Google's privacy policy (https://policies.google.com/privacy) and is not used to identify you.
? Allow Firebase to collect CLI and Emulator Suite usage and error reporting information? (Y/n)
n データ収集しない

### Firebaseサービスを追加する
% cd ~/pc_data/project/scal
% fvm flutter pub add firebase_core
% fvm flutter pub add firebase_analytics
% fvm flutter pub add firebase_crashlytics

### プロジェクトにFirebaseを適用/初期化する
% flutterfire configure
? You have an existing `firebase.json` file and possibly already configured your project for Firebase. Would you prefer to reuse the values in your existing `firebase.json` file to configure your project? (y/n) › yes
yes 既存のfirebase.jsonを使用

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
vi ./android/settings.gradle
plugins {
id "com.android.application" version "8.12.0" apply false
3.Gradleを更新する(Android)
vi ./android/gradle/wrapper/gradle-wrapper.properties
distributionUrl=https\://services.gradle.org/distributions/gradle-9.2.0-bin.zip
4.ライブラリを更新する(Android)
/Users/ryota24/pc_data/project/scal/pubspec.yaml
5.Androidリリースファイル作成時のエラーから、AGP8.4以降の圧縮で、圧縮ファイルを追加する(Android)
vi ./android/app/proguard-rules.pro