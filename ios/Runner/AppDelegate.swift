import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var content: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let fileChannel = FlutterMethodChannel(name: "de.wekode.mml/import_favs", binaryMessenger: controller as! FlutterBinaryMessenger)

    fileChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: FlutterResult) -> Void in
      if call.method == "getOpenFileUrl" {
        if self.content != nil {
            result(self.content)
            self.content = nil
        }
      } else {
        result(FlutterMethodNotImplemented)
        return
      }
    
    })
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    content = try? String(contentsOf: url, encoding: .utf8)
    return true
  }
}
