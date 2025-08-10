# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.builttoroam.devicecalendar.** { *; }

# AGP8.4

# Flutterエンジン関連
-keep class io.flutter.embedding.engine.** { *; }
# プラットフォームビューとタッチ処理
-keep class io.flutter.plugin.platform.** { *; }
# レンダリング関連
-keep class io.flutter.embedding.engine.renderer.** { *; }
# Androidネイティブタッチ処理
-keep class androidx.core.view.** { *; }
# スクロール関連
-keep class androidx.core.widget.** { *; }
-keep class androidx.recyclerview.widget.** { *; }
# Google API/Firebase
-keep class com.google.api.client.** { *; }
-keep class com.google.firebase.** { *; }

# Flutterエンジン関連
-dontwarn io.flutter.embedding.engine.**
# プラットフォームビューとタッチ処理
-dontwarn io.flutter.plugin.platform.**
# レンダリング関連
-dontwarn io.flutter.embedding.engine.renderer.**
-dontwarn impeller.**
# Androidネイティブタッチ処理
-dontwarn android.view.MotionEvent
-dontwarn androidx.core.view.**
# スクロール関連
-dontwarn androidx.core.widget.**
-dontwarn androidx.recyclerview.widget.**
# Google API/Firebase
-dontwarn com.google.api.client.**
-dontwarn com.google.firebase.**

# ミスした設定の追加(scal/build/app/outputs/mapping/release/missing_rules.txt)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task