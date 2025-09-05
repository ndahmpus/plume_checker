# Plume Portal ProGuard Rules
# Keep source file names and line numbers for better crash reports
-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep HTTP related classes for API calls
-keep class java.net.** { *; }
-keep class javax.net.ssl.** { *; }
-keep class org.apache.http.** { *; }

# Keep Web3 related classes if using web3dart
-keep class org.web3j.** { *; }
-keep class com.fasterxml.jackson.** { *; }

# Keep application classes
-keep class com.plume.portal.** { *; }

# General Android rules
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

# Keep native method names
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep setters and getters for model classes
-keepclassmembers public class * {
   void set*(***);
   *** get*();
}

# Keep enum classes
-keepclassmembers enum * { *; }

# Keep Parcelable implementation
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Google Play Core API - suppress warnings for missing classes
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
