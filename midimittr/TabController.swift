//  Created by Matthias Frick on 27.12.2017.

import UIKit

class TabController: UITabBarController {

  var appContext: AppContext! {
    didSet {
      //swiftlint:disable:next force_cast
      let midiPortVC = self.viewControllers![0] as! MIDIPortsViewController
      midiPortVC.midiController = appContext.midiController
      //swiftlint:disable:next force_cast
      let usbVC = self.viewControllers![3] as! USBConnectionTableViewController
      usbVC.peerTalkBridge = appContext.peerTalkBridge
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let settingsImage = UIImage(imageLiteralResourceName: "settings")
    let settingsButton = UIBarButtonItem(image: settingsImage, style: .done,
                                         target: self, action: #selector(openSettings))
    self.navigationItem.rightBarButtonItem = settingsButton
    let midiMittrImage = UIImage(imageLiteralResourceName: "topIcon").withRenderingMode(.alwaysOriginal)
    let midiMittrButton = UIBarButtonItem(image: midiMittrImage, style: .plain,
                                          target: self, action: #selector(openWebPage))
    self.navigationItem.leftBarButtonItem = midiMittrButton
    //swiftlint:disable:next force_cast
    let usbVC = self.viewControllers![3] as! USBConnectionTableViewController
    usbVC.peerTalkBridge = appContext.peerTalkBridge
  }

  @objc func openSettings() {
    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
  }

  @objc func openWebPage() {
    let url = URL(string: "http://www.s-r-n.de/midimittr")!
    let alert = UIAlertController(title: "midiMittr Website",
                                  message: "Open midiMittr Website?", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }))
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    present(alert, animated: false, completion: nil)
  }
}
