//
//  TodayViewController.swift
//  midimittr le
//
//  Created by Matthias Frick on 25/09/2019.
//  Copyright © 2019 Matthias Frick. All rights reserved.
//

import CoreAudioKit
import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

  @IBOutlet weak var connectButton: UISegmentedControl!

  var bluetoothView: UIView!
    override func viewDidLoad() {
      super.viewDidLoad()
      extensionContext?.widgetLargestAvailableDisplayMode = .expanded
      let maxSize = self.extensionContext?.widgetMaximumSize(for: .expanded)

      bluetoothView = UIView(frame: CGRect(x: 10, y: 20, width: maxSize!.width - 50,
                                           height: 400 - 20))
      self.view.addSubview(bluetoothView)
      self.connectButton.addTarget(self, action: #selector(showBluetooth), for: .valueChanged)
      showBluetooth()
    }

  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    if activeDisplayMode == .expanded {
      preferredContentSize = CGSize(width: 0, height: 400)
      showBluetooth()
    } else {
      preferredContentSize = CGSize(width: 0, height: 20)
      showBluetooth()
    }
  }

  @objc func showBluetooth() {
    for bleView in self.bluetoothView.subviews {
      bleView.removeFromSuperview()
    }

    if self.extensionContext!.widgetActiveDisplayMode == .compact {
      let expandLabel = createExpandLabel(bluetoothView)
      bluetoothView.addSubview(expandLabel)
      return
    }

    let segment = connectButton.selectedSegmentIndex
    let bleVC = segment == 0 ? CABTMIDILocalPeripheralViewController() : CABTMIDICentralViewController()
    bleVC.view.frame = bluetoothView.frame
    bleVC.willMove(toParent: self)
    bluetoothView.addSubview(bleVC.view)
  }

  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    completionHandler(NCUpdateResult.newData)
  }
}

extension TodayViewController {
  func createExpandLabel(_ superView: UIView) -> UILabel {
    let expandLabel = UILabel()
    expandLabel.text = "Expand to see MIDI Settings"
    expandLabel.tintColor = UIColor(named: "labelColor")
    expandLabel.sizeThatFits(superView.frame.size)
    expandLabel.frame = CGRect(x: superView.frame.origin.x,
                               y: superView.frame.origin.y + 20,
                               width: superView.frame.size.width, height: 30)
    expandLabel.textAlignment = .center
    return expandLabel
  }
}
