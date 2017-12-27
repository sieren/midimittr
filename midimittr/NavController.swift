//  Copyright © 2017 Matthias Frick. All rights reserved.

import UIKit

class NavController: UINavigationController {

  var appContext: AppContext!
  var titleLabel: UILabel!
  var activityTimer: Timer?

  override func viewDidLoad() {
    super.viewDidLoad()
    //swiftlint:disable:next force_cast
    let tabController = self.viewControllers[0] as! TabController
    tabController.appContext = appContext
    let attributeThin = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: .light) ]
    let attributeBold = [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18, weight: .bold) ]
    let midiStr = NSMutableAttributedString(string: "midi", attributes: attributeThin)
    let mittrStr = NSAttributedString(string: "mittr", attributes: attributeBold)
    midiStr.append(mittrStr)
    titleLabel = UILabel()
    titleLabel.attributedText = midiStr
    self.navigationBar.topItem?.titleView = titleLabel
    registerActivityAnimation()
  }

  func registerActivityAnimation() {
    appContext.midiController.activityCallback = {
      self.activityTimer?.invalidate()
      self.titleLabel.textColor = .red
      // UILabel.textColor does not support animation
      // Use timer with selector for iOS 8 compatibilty
      self.activityTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self,
                                                selector: #selector(self.resetLabelColor),
                                                userInfo: nil, repeats: false)
    }
  }

  @objc func resetLabelColor() {
    self.titleLabel.textColor = .black
  }
}
