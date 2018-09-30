//  Copyright © 2017 Sieren. All rights reserved.

import UIKit
import NotificationBanner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PeerTalkConnectionProtocol {

  var window: UIWindow?
  var banner: NotificationBanner?
  var appContext = AppContext()
  let appDefaults = [String: AnyObject]()

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    registerSettingsBundle()
    appContext.peerTalkBridge.connectionViewDelegate = self
    //swiftlint:disable:next force_cast
    let root = self.window!.rootViewController as! NavController
    root.appContext = appContext
    NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.defaultsChanged),
                                           name: UserDefaults.didChangeNotification, object: nil)
    defaultsChanged()
    return true
  }

  func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                   restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    //swiftlint:disable:next force_cast
    let root = self.window!.rootViewController as! NavController
    root.appContext = appContext
    switch userActivity.activityType {
    case "com.matt.MIDI-LE.advertise":
      root.tabController.selectedIndex = 1
    case "com.matt.MIDI-LE.clients":
      root.tabController.selectedIndex = 2
    default:
      break
    }
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

  // MARK: Status Bar Notification

  func didConnectToUSB() {
    banner?.dismiss()
    banner = NotificationBanner(title: "USB Connection", subtitle: "Device connected.", style: .success)
    banner?.show()
  }

  func didDisconnectFromUSB() {
    banner?.dismiss()
    banner = NotificationBanner(title: "USB Connection", subtitle: "Device disconnected.", style: .warning)
    banner?.show()
  }

  // MARK: App Settings

  func registerSettingsBundle() {
    let appDefaults = ["backgroundaudio": true, "usbconnectivity": true, "siriButtonActive": true]
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
