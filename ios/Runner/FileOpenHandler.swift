import UIKit
import Flutter

/// Passes the content of files opened with the app to Flutter.
class FileOpenHandler: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  private static let maxFileSize = 100 * 1024 * 1024
  private var content: String?
  private var error: String?

  /// Registers the handler for the file channel and the scene events.
  static func register(with registrar: FlutterPluginRegistrar) {
    let instance = FileOpenHandler()
    let channel = FlutterMethodChannel(name: "de.wekode.mml", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addSceneDelegate(instance)
  }

  /// Returns the content of the last opened file or the error on reading it
  /// once.
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getOpenFileUrl" {
      if let code = error {
        result(FlutterError(code: code, message: nil, details: FileOpenHandler.maxFileSize / (1024 * 1024)))
        error = nil
      } else if content != nil {
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

    let isScoped = url.startAccessingSecurityScopedResource()
    defer {
      if isScoped {
        url.stopAccessingSecurityScopedResource()
      }
    }
    content = nil
    error = nil
    if let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize, size > FileOpenHandler.maxFileSize {
      error = "fileTooLarge"
      return true
    }

    content = try? String(contentsOf: url, encoding: .utf8)
    if content == nil {
      error = "fileNotReadable"
    }
    return true
  }
}
