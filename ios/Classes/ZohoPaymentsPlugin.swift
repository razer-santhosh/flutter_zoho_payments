import Flutter
import UIKit
#if canImport(ZohoPayments)
import ZohoPayments
#endif

public class ZohoPaymentsPlugin: NSObject, FlutterPlugin {
    private var pendingResult: FlutterResult?
    private var isPaymentInProgress = false

    private var apiKey: String?
    private var accountId: String?

    #if canImport(ZohoPayments)
    private var checkoutSandbox: ZohoPaymentsCheckout?
    private var checkoutLive: ZohoPaymentsCheckout?
    #endif

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "zoho_payments", binaryMessenger: registrar.messenger())
        let instance = ZohoPaymentsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "startPayment":
            handleStartPayment(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let apiKey = args["apiKey"] as? String,
              let accountId = args["accountId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "apiKey and accountId are required",
                                details: nil))
            return
        }

        self.apiKey = apiKey
        self.accountId = accountId

        #if canImport(ZohoPayments)
        // Lazily build per-environment checkout instances during startPayment.
        // We just cache credentials here to mirror the Android contract.
        result(true)
        #else
        result(FlutterError(code: "SDK_MISSING",
                            message: "ZohoPayments iOS SDK is not linked. Add the Swift Package https://github.com/zoho/zpayments-ios-sdk to your Runner target.",
                            details: nil))
        #endif
    }

    private func handleStartPayment(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        #if canImport(ZohoPayments)
        guard let apiKey = self.apiKey, let accountId = self.accountId else {
            result(FlutterError(code: "NOT_INITIALIZED",
                                message: "initialize() must be called before startPayment()",
                                details: nil))
            return
        }

        guard let args = call.arguments as? [String: Any],
              let paymentSessionId = args["paymentSessionId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS",
                                message: "paymentSessionId is required",
                                details: nil))
            return
        }

        let description = (args["description"] as? String) ?? ""
        let customerName = (args["customerName"] as? String) ?? ""
        let customerEmail = (args["customerEmail"] as? String) ?? ""
        let customerPhone = (args["customerPhone"] as? String) ?? ""
        let environmentString = (args["environment"] as? String) ?? "sandbox"
        let paymentMethodString = args["paymentMethod"] as? String

        guard let viewController = topViewController() else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER",
                                message: "No active UIViewController to present checkout",
                                details: nil))
            return
        }

        let environment: ZohoPaymentsEnvironment = (environmentString == "live") ? .live : .sandbox
        let checkout = checkoutInstance(for: environment, apiKey: apiKey, accountId: accountId)

        let options = CheckoutOptions(
            paymentSessionId: paymentSessionId,
            description: description,
            invoiceNumber: "",
            referenceNumber: "",
            name: customerName,
            email: customerEmail,
            phone: customerPhone,
            paymentMethod: mapPaymentMethod(paymentMethodString)
        )

        self.pendingResult = result
        self.isPaymentInProgress = true

        DispatchQueue.main.async {
            checkout.open(on: viewController, with: options)
        }
        #else
        result(FlutterError(code: "SDK_MISSING",
                            message: "ZohoPayments iOS SDK is not linked. Add the Swift Package https://github.com/zoho/zpayments-ios-sdk to your Runner target.",
                            details: nil))
        #endif
    }

    private func topViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        var top = keyWindow?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    #if canImport(ZohoPayments)
    private func checkoutInstance(for environment: ZohoPaymentsEnvironment,
                                  apiKey: String,
                                  accountId: String) -> ZohoPaymentsCheckout {
        switch environment {
        case .live:
            if let cached = checkoutLive { return cached }
            let instance = ZohoPaymentsCheckout(apiKey: apiKey,
                                                accountId: accountId,
                                                domain: .IN,
                                                environment: .live,
                                                withCheckoutDelegate: self)
            checkoutLive = instance
            return instance
        default:
            if let cached = checkoutSandbox { return cached }
            let instance = ZohoPaymentsCheckout(apiKey: apiKey,
                                                accountId: accountId,
                                                domain: .IN,
                                                environment: .sandbox,
                                                withCheckoutDelegate: self)
            checkoutSandbox = instance
            return instance
        }
    }

    private func mapPaymentMethod(_ value: String?) -> PaymentMethod? {
        switch value {
        case "card": return .CARD
        case "netBanking": return .NET_BANKING
        case "upi": return .UPI
        default: return nil
        }
    }
    #endif
}

#if canImport(ZohoPayments)
extension ZohoPaymentsPlugin: ZohoPaymentsCheckoutDelegate {
    public func onPaymentSuccess(object: PaymentSuccessObject) {
        guard isPaymentInProgress, let pending = pendingResult else { return }
        let payload: [String: Any?] = [
            "status": "success",
            "paymentId": object.paymentId,
            "signature": object.signature
        ]
        pending(payload)
        pendingResult = nil
        isPaymentInProgress = false
    }

    public func onPaymentFailure(object: PaymentFailureObject) {
        guard isPaymentInProgress, let pending = pendingResult else { return }
        let message = object.message
        let isCancellation = message.lowercased().contains("cancel")
        let payload: [String: Any?] = [
            "status": isCancellation ? "cancelled" : "failure",
            "errorMessage": message
        ]
        pending(payload)
        pendingResult = nil
        isPaymentInProgress = false
    }
}
#endif
