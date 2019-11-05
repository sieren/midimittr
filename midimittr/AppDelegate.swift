//  Copyright © 2017 Sieren. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var notificationDisplay = ScreenNotifications()
  var appContext = AppContext()
  let appDefaults = [String: AnyObject]()

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    registerSettingsBundle()
    appContext.peerTalkBridge.connectionViewDelegate = notificationDisplay
    //swiftlint:disable:next force_cast
    let root = self.window!.rootViewController as! NavController
    root.appContext = appContext
    NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.defaultsChanged),
                                           name: UserDefaults.didChangeNotification, object: nil)
    defaultsChanged()
    return true
  }

  @available(iOS 9.0, *)
  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem,
                   completionHandler: @escaping (Bool) -> Void) {
    //swiftlint:disable:next force_cast
    let root = self.window?.rootViewController as! NavController
    //swiftlint:disable:next force_cast
    let tabController = root.viewControllers[0] as! TabController
    switch shortcutItem.type {
    case "com.matt.midimittr.advertise":
      tabController.selectedIndex = 1
    case "com.matt.midimittr.clients":
      tabController.selectedIndex = 2
    default:
      fatalError("Unsupported ShortcutItem")
    }
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    appContext.peerTalkBridge.checkAndRestartNetwork()
  }

  // MARK: App Settings

  func registerSettingsBundle() {
    let appDefaults = ["backgroundaudio": true, "usbconnectivity": true]
    UserDefaults.standard.register(defaults: appDefaults)
  }

  @objc func defaultsChanged() {
    appContext.peerTalkBridge.setActive(UserDefaults.standard.bool(forKey: "usbconnectivity"))
    if !UserDefaults.standard.bool(forKey: "backgroundaudio") {
      appContext.midiController.stopBackgrounding()
    } else {
      appContext.midiController.startBackgrounding()
    }
  }
}
