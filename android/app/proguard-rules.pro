# =============================================================================
# KG Auto – R8 / ProGuard rules
# =============================================================================
# Flutter's Android embedding and generated plugin registration are normally
# handled by the Flutter Gradle plugin. These app-level rules keep reflective
# entry points stable when R8 is enabled.
# =============================================================================

# --------------- Flutter core ---------------
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-dontwarn io.flutter.**

# --------------- Firebase core / messaging / in-app messaging ---------------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class io.flutter.plugins.firebase.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# --------------- AndroidX & Jetpack ---------------
-keep class androidx.** { *; }
-dontwarn androidx.**

# --------------- flutter_local_notifications ---------------
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# --------------- WebView / webview_flutter ---------------
# Preserve WebViewClient callbacks that are called reflectively on older APIs.
-keep class android.webkit.** { *; }
-keepclassmembers class * extends android.webkit.WebViewClient {
    public void *(android.webkit.WebView, java.lang.String, android.graphics.Bitmap);
    public boolean *(android.webkit.WebView, java.lang.String);
}

# --------------- image_picker / file_picker ---------------
-keep class androidx.activity.result.** { *; }

# --------------- Sqflite ---------------
-keep class com.tekartik.sqflite.** { *; }

# --------------- video_thumbnail ---------------
-keep class xyz.justsoft.video_thumbnail.** { *; }

# --------------- gallery_saver (local path dep) ---------------
-keep class com.example.gallery_saver.** { *; }

# --------------- share_plus ---------------
-keep class dev.fluttercommunity.plus.share.** { *; }

# --------------- permission_handler ---------------
-keep class com.baseflow.permissionhandler.** { *; }

# --------------- open_file ---------------
-keep class com.crazecoder.openfile.** { *; }

# --------------- Syncfusion charts ---------------
-keep class com.syncfusion.** { *; }

# --------------- Kotlin coroutines / stdlib ---------------
-dontwarn kotlin.**
-dontwarn kotlinx.**
-keep class kotlin.** { *; }
-keep class kotlinx.coroutines.** { *; }

# --------------- Gson / JSON (used by several plugins) ---------------
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# --------------- General safety rules ---------------
# Keep Parcelable implementations.
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}
# Keep Serializable implementations.
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}
# Keep enum values.
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
