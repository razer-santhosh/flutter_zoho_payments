# Zoho Payments SDK ProGuard rules
-keep class com.zoho.paymentsdk.** { *; }
-keepclassmembers class com.zoho.paymentsdk.** { *; }
-dontwarn com.zoho.paymentsdk.**

# Keep plugin classes
-keep class com.yourcompany.zoho_payments.** { *; }