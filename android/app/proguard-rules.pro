# Flutter Proguard Rules

# Keep Flutter/Dart internals
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }

# Keep Firebase/GMS classes to avoid over-shrinking
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.** { *; }

# Suppress warnings for missing references
-dontwarn io.flutter.embedding.handshake.**
-dontwarn com.google.android.play.core.**

# Preservation rules for Audio/Video (Exoplayer) and Serialization
-keepattributes Signature, InnerClasses, AnnotationDefault, EnclosingMethod
-dontwarn com.google.android.exoplayer2.**
-keep class com.google.android.exoplayer2.** { *; }
-keep class com.google.gson.** { *; }
-dontwarn com.google.android.gms.internal.**

# WebView / JavaScript Interface rules for youtube_player_iframe
-keepattributes JavascriptInterface
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class androidx.webkit.** { *; }
-keep class io.flutter.plugins.webviewflutter.** { *; }
