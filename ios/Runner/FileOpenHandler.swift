import UIKit
import Flutter

/// Passes the content of files opened with the app to Flutter.
class FileOpenHandler: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  private var content: String?

  /// Registers the handler for the file channel and the scene events.
  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FileOpenHandler()
    let channel = FlutterMethodChannel(name: "de.wekode.mml", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addSceneDelegate(instance)
  }

  /// Returns the content of the last opened file once.
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getOpenFileUrl" {
      if content != nil {
        result(content)
        content = nil
      }
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  /// Keeps the file the app was launched with.
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    return open(connectionOptions?.urlContexts ?? [])
  }

  /// Keeps the file opened while the app is running.
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    return open(URLContexts)
  }

  private func open(_ contexts: Set<UIOpenURLContext>) -> Bool {
    guard let url = contexts.first?.url else {
      return false
    }

    content = try? String(contentsOf: url, encoding: .utf8)
    return true
  }
}
