package com.flutter.zoho_payments

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import com.zoho.paymentsdk.CheckoutSDK
import com.zoho.paymentsdk.model.CheckoutOptions
import com.zoho.paymentsdk.model.PaymentMethod
import com.zoho.paymentsdk.ZohoPayCheckoutCallback
import com.zoho.paymentsdk.ZohoPayDomain
import com.zoho.paymentsdk.ZohoPaymentsEnvironment

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent

/** ZohoPaymentsPlugin */
class ZohoPaymentsPlugin: FlutterPlugin, MethodCallHandler, ActivityAware, LifecycleObserver {
  private lateinit var channel : MethodChannel
  private var activity: Activity? = null
  private var activityBinding: ActivityPluginBinding? = null
  private var pendingResult: Result? = null
  private var isPaymentInProgress = false
  private var context: Context? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zoho_payments")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "initialize" -> {
        val apiKey = call.argument<String>("apiKey")
        val accountId = call.argument<String>("accountId")

        if (apiKey == null || accountId == null) {
          result.error("INVALID_ARGUMENTS", "apiKey and accountId are required", null)
          return
        }

        try {
          CheckoutSDK.initialize(apiKey, accountId)
          result.success(true)
        } catch (e: Exception) {
          result.error("INIT_ERROR", "Failed to initialize Zoho Payments SDK: ${e.message}", null)
        }
      }
      "startPayment" -> {
        if (activity == null) {
          result.error("NO_ACTIVITY", "Activity is not available", null)
          return
        }

        val paymentSessionId = call.argument<String>("paymentSessionId")
        val description = call.argument<String>("description") ?: ""
        val customerName = call.argument<String>("customerName") ?: ""
        val customerEmail = call.argument<String>("customerEmail") ?: ""
        val customerPhone = call.argument<String>("customerPhone") ?: ""
        val paymentMethodString = call.argument<String>("paymentMethod")
        
        val paymentMethod = when(paymentMethodString) {
          "card" -> PaymentMethod.CARD
          "netBanking" -> PaymentMethod.NET_BANKING
          "upi" -> PaymentMethod.UPI
          else -> null
        }

        if (paymentSessionId == null) {
          result.error("INVALID_ARGUMENTS", "paymentSessionId is required", null)
          return
        }

        pendingResult = result
        isPaymentInProgress = true

        try {
          val checkoutOptions = CheckoutOptions(
            paymentSessionId,  // paymentSessionId
            description,       // description
            "",                // invoiceNumber (optional)
            "",                // referenceNumber (optional)
            customerName,      // name
            customerEmail,     // email
            customerPhone,     // phone
            paymentMethod      // paymentMethod (optional)
          )

          // TODO: Make domain and environment configurable
          CheckoutSDK.showCheckout(
            activity!!,
            checkoutOptions,
            ZohoPayDomain.IN,
            ZohoPaymentsEnvironment.production, // Use production by default
            object : ZohoPayCheckoutCallback {
              override fun onPaymentSuccess(paymentId: String, signature: String) {
                val resultMap = hashMapOf<String, Any?>(
                  "status" to "success",
                  "paymentId" to paymentId,
                  "signature" to signature
                )
                pendingResult?.success(resultMap)
                pendingResult = null
                isPaymentInProgress = false
              }

              override fun onPaymentFailure(error: String) {
                val resultMap = hashMapOf<String, Any?>(
                  "status" to "failure",
                  "errorMessage" to error
                )
                pendingResult?.success(resultMap)
                pendingResult = null
                isPaymentInProgress = false
              }
            }
          )
        } catch (e: Exception) {
          pendingResult?.error("PAYMENT_ERROR", "Failed to start payment: ${e.message}", null)
          pendingResult = null
          isPaymentInProgress = false
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    activityBinding = binding
    
    // Add lifecycle observer to handle resume events
    if (activity is androidx.lifecycle.LifecycleOwner) {
      (activity as androidx.lifecycle.LifecycleOwner).lifecycle.addObserver(this)
    }
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    // Remove lifecycle observer
    if (activity is androidx.lifecycle.LifecycleOwner) {
      (activity as androidx.lifecycle.LifecycleOwner).lifecycle.removeObserver(this)
    }
    
    // Handle payment cancellation when activity is detached
    if (isPaymentInProgress && pendingResult != null) {
      val resultMap = hashMapOf<String, Any?>(
        "status" to "cancelled",
        "errorMessage" to "Payment cancelled by user"
      )
      pendingResult?.success(resultMap)
      pendingResult = null
      isPaymentInProgress = false
    }
    
    activity = null
    activityBinding = null
  }

  @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
  fun onActivityResumed() {
    // Check if payment was in progress and handle back gesture
    if (isPaymentInProgress && pendingResult != null) {
      // Delay check to ensure Zoho SDK had time to process the result
      activity?.runOnUiThread {
        android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
          // If still in progress after delay, it means user pressed back
          if (isPaymentInProgress && pendingResult != null) {
            val resultMap = hashMapOf<String, Any?>(
              "status" to "cancelled",
              "errorMessage" to "Payment cancelled by user"
            )
            pendingResult?.success(resultMap)
            pendingResult = null
            isPaymentInProgress = false
          }
        }, 500) // 500ms delay to let SDK callbacks fire first
      }
    }
  }
}