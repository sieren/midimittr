//  Copyright © 2017 Matthias Frick. All rights reserved.

import UIKit
import CoreAudioKit

class BLEAdvertViewController: UIViewController {

  private var bleVC = CABTMIDILocalPeripheralViewController()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.addChildViewController(bleVC)
    bleVC.view.frame = self.view.frame
    view.addSubview(bleVC.view)
    bleVC.didMove(toParentViewController: self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController!.navigationBar.topItem?.title = "Bluetooth Advertising"
    setupIntents()
  }

  func setupIntents() {
    let activity = NSUserActivity(activityType: "com.matt.MIDI-LE.advertise")
    activity.title = "Advertise as Bluetooth MIDI Client"
    activity.isEligibleForSearch = true
    if #available(iOS 12.0, *) {
      activity.isEligibleForPrediction = true
      activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: "com.matt.MIDI-LE.advertise")
    } else {
      // do nothing
    }
    view.userActivity = activity
    activity.becomeCurrent()
  }
}
