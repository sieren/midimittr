//  Copyright © 2017 Matthias Frick. All rights reserved.

import UIKit
import CoreAudioKit

class BLEClientViewController: UIViewController {

  private var bleClientVC = CABTMIDICentralViewController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bleClientVC.view.frame = self.view.frame
    view.addSubview(bleClientVC.view)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    for subView in view.subviews {
//      subView.removeFromSuperview()
//    }
//    var bleVC = CABTMIDICentralViewController()
//    bleVC.view.frame = self.view.frame
//    view.addSubview(bleVC.view)
    self.navigationController!.navigationBar.topItem?.title = "Bluetooth Clients"
  }
}
