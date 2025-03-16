import Flutter
import UIKit
import Firebase
import FirebaseMessaging
import FBSDKCoreKit
import FBSDKLoginKit // Facebook SDK
import GoogleSignIn // Google Sign-In SDK

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      application.registerForRemoteNotifications()
    // Khởi tạo plugin Flutter
    GeneratedPluginRegistrant.register(with: self)
      
    // Khởi tạo Facebook SDK
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )

    // Khởi tạo Google Sign-In (không bắt buộc, nhưng thêm để chắc chắn)
    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
      if let error = error {
        print("Restore previous sign-in failed: \(error.localizedDescription)")
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

           Messaging.messaging().apnsToken = deviceToken
           super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
         }
    
    override func application(
          _ application: UIApplication,
          didReceiveRemoteNotification userInfo: [AnyHashable: Any],
          fetchCompletionHandler completionHandler:
          @escaping (UIBackgroundFetchResult) -> Void
        ) {
          guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
          }
          print(aps)
        }

  // Xử lý URL cho iOS 12 trở xuống
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    let facebookHandled = ApplicationDelegate.shared.application(
      app,
      open: url,
      sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
      annotation: options[UIApplication.OpenURLOptionsKey.annotation]
    )
    let googleHandled = GIDSignIn.sharedInstance.handle(url)

    // Trả về true nếu một trong hai xử lý thành công
    return facebookHandled || googleHandled || super.application(app, open: url, options: options)
  }

  // Xử lý URL cho iOS 13+ (Scene Delegate)
  @available(iOS 13.0, *)
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url else { return }

    // Xử lý URL cho Facebook
    _ = ApplicationDelegate.shared.application(
      UIApplication.shared,
      open: url,
      sourceApplication: nil,
      annotation: [UIApplication.OpenURLOptionsKey.annotation]
    )

    // Xử lý URL cho Google
    _ = GIDSignIn.sharedInstance.handle(url)
  }
}
