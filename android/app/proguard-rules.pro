# ─────────────────────────────────────────────────────────────────────────────
# NutriPump — ProGuard / R8 Keep Rules for Release Builds
# ─────────────────────────────────────────────────────────────────────────────

# ── Flutter ────────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# ── Razorpay ───────────────────────────────────────────────────────────────────
# Required per Razorpay's official integration guide to prevent payment crashes.
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** { *; }
-optimizations !method/inlining/*

# ── Firebase ───────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ── Google Sign-In ─────────────────────────────────────────────────────────────
-keep class com.google.android.gms.auth.** { *; }

# ── OkHttp / Retrofit (used by Firebase & Razorpay internally) ─────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# ── General safety ─────────────────────────────────────────────────────────────
-keepattributes Signature
-keepattributes Exceptions
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ── Play Core (Flutter deferred components — not used but referenced) ──────────
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn com.google.android.play.core.splitcompat.**

