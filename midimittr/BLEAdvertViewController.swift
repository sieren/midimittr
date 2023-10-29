//  Copyright © 2017 Matthias Frick. All rights reserved.

import UIKit
import CoreAudioKit

class BLEAdvertViewController: CABTMIDILocalPeripheralViewController {


  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    for subView in view.subviews {
//      subView.removeFromSuperview()
//    }
//    var bleVC = CABTMIDILocalPeripheralViewController()
 //   bleVC.view.frame = self.view.frame
//    view.addSubview(bleVC.view)
    self.navigationController!.navigationBar.topItem?.title = "Bluetooth Advertising"
  }
}
