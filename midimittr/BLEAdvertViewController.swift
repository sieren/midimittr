//  Copyright © 2017 Matthias Frick. All rights reserved.

import UIKit
import CoreAudioKit

class BLEAdvertViewController: UIViewController {

  private var bleVC = CABTMIDILocalPeripheralViewController()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.addChildViewController(bleVC)
    if let rect = self.navigationController?.navigationBar.frame {
      let y = rect.size.height + rect.origin.y
      bleVC.view.frame =  view.frame.offsetBy(dx: 0, dy: y)
    }
    view.addSubview(bleVC.view)
    bleVC.didMove(toParentViewController: self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController!.navigationBar.topItem?.title = "Bluetooth Advertising"
  }
}
