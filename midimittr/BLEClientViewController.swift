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
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}
