//  Copyright © 2017 Matthias Frick. All rights reserved.

import Foundation


class AppContext {

  var midiController: MIDIController!
  var peerTalkBridge: PeerTalkBridge!
  private var _activityViewHandler: Any? = nil
  @available(iOS 16.2, *)
  fileprivate var activityViewHandler: ActivityViewHandler {
      if _activityViewHandler == nil {
        _activityViewHandler = ActivityViewHandler(midiController: self.midiController)
      }
      return _activityViewHandler as! ActivityViewHandler
  }

  public func didBecomeActive() {
    if #available(iOS 16.2, *), !ProcessInfo.processInfo.isiOSAppOnMac {
      activityViewHandler.updateResources()
    }
  }

  init() {
    self.midiController = MIDIController()
    self.peerTalkBridge = PeerTalkBridge(midiDelegate: self.midiController)
    if #available(iOS 16.2, *), !ProcessInfo.processInfo.isiOSAppOnMac {
      activityViewHandler.start()
    } else {
      // Fallback on earlier versions
    }
  }
}
