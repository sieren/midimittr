//
//  Notifications.swift
//  midimittr
//
//  Created by Matthias Frick on 05/11/2019.
//  Copyright © 2019 Matthias Frick. All rights reserved.
//

import Foundation

#if !targetEnvironment(macCatalyst)
import NotificationBanner

class ScreenNotifications: PeerTalkConnectionProtocol {
  var banner: NotificationBanner?
  static let shared = Notifications()

  public func didConnectToUSB() {
    banner?.dismiss()
    banner = NotificationBanner(title: "USB Connection", subtitle: "Device connected.", style: .success)
    banner?.show()
  }

  public func didDisconnectFromUSB() {
    banner?.dismiss()
    banner = NotificationBanner(title: "USB Connection", subtitle: "Device disconnected.", style: .warning)
    banner?.show()
  }
}
#endif

#if targetEnvironment(macCatalyst)
class ScreenNotifications: PeerTalkConnectionProtocol {

  public func didConnectToUSB() {
    // NO OP
  }

  public func didDisconnectFromUSB() {
    // NO OP
  }
}

#endif
