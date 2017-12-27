//  Copyright © 2017 Matthias Frick. All rights reserved.

import Foundation

class AppContext {

  var midiController: MIDIController!
  var peerTalkBridge: PeerTalkBridge!

  init() {
    self.midiController = MIDIController()
    self.peerTalkBridge = PeerTalkBridge(midiDelegate: self.midiController)
  }
}
