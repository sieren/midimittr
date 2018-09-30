//  Copyright © 2017 Matthias Frick. All rights reserved.

import UIKit
import CoreAudioKit

class BLEClientViewController: UIViewController {

  private var bleClientVC = CABTMIDICentralViewController()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.addChildViewController(bleClientVC)
    bleClientVC.view.frame = self.view.frame
    view.addSubview(bleClientVC.view)
    bleClientVC.didMove(toParentViewController: self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController!.navigationBar.topItem?.title = "Bluetooth Clients"
    setupIntents()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  func setupIntents() {
    let activity = NSUserActivity(activityType: "com.matt.MIDI-LE.clients")
    activity.title = "Browse for Bluetooth MIDI Clients"
    activity.isEligibleForSearch = true
    if #available(iOS 12.0, *) {
      activity.isEligibleForPrediction = true
      activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: "com.matt.MIDI-LE.clients")
    } else {
      // do nothing
    }
    view.userActivity = activity
    activity.becomeCurrent()
  }
}
