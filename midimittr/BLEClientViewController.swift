//  Copyright © 2017 Matthias Frick. All rights reserved.

import UIKit
import CoreAudioKit
import CoreSpotlight
import Intents
import IntentsUI

class BLEClientViewController: UIViewController, INUIAddVoiceShortcutViewControllerDelegate {

  private var bleClientVC = CABTMIDICentralViewController()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.addChildViewController(bleClientVC)
    bleClientVC.view.frame = self.view.frame
    view.addSubview(bleClientVC.view)
    bleClientVC.didMove(toParentViewController: self)

    if #available(iOS 12.0, *) {
      if !UserDefaults.standard.bool(forKey: "siriButtonActive") { return }
      let activity = getActivityForCurrentView()
      let shortcut = INShortcut(userActivity: activity)
      setupSiriButton(with: shortcut)
    } else {
      // do nothing
    }
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
    let activity = getActivityForCurrentView()
    view.userActivity = activity
    activity.becomeCurrent()
  }

  func getActivityForCurrentView() -> NSUserActivity {
    let activity = NSUserActivity(activityType: "com.matt.MIDI-LE.clients")
    activity.title = "Browse"
    activity.isEligibleForSearch = true
    if #available(iOS 12.0, *) {
      activity.isEligibleForPrediction = true
      activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: "com.matt.MIDI-LE.clients")

      let attributes = CSSearchableItemAttributeSet(itemContentType: "com.matt.MIDI-LE.clients")
      attributes.keywords = ["MIDI", "Clients", "Browse", "Search", "Bluetooth", "Look"]
      attributes.displayName = "Browse"
      attributes.contentDescription = "Look for Bluetooth MIDI Clients"
      activity.contentAttributeSet = attributes
    } else {
      // do nothing
    }
    return activity
  }

  @available(iOS 12.0, *)
  @objc
  func addToSiri(_ sender: Any) {
    let activity = getActivityForCurrentView()
    let shortcut = INShortcut(userActivity: activity)
    let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
    viewController.modalPresentationStyle = .formSheet
    viewController.delegate = self
    present(viewController, animated: true, completion: nil)
  }

  @available(iOS 12.0, *)
  func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController,
                                      didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
    dismiss(animated: true, completion: nil)
  }

  @available(iOS 12.0, *)
  func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
    dismiss(animated: true, completion: nil)
  }

  @available(iOS 12.0, *)
  func setupSiriButton(with shortCut: INShortcut) {
    let siriButton = INUIAddVoiceShortcutButton(style: .white)
    siriButton.shortcut = shortCut
    siriButton.addTarget(self, action: #selector(addToSiri(_:)), for: .touchUpInside)

    let toolbar = UIView()
    toolbar.backgroundColor = .white
    toolbar.isUserInteractionEnabled = true

    toolbar.translatesAutoresizingMaskIntoConstraints = false
    bleClientVC.view.translatesAutoresizingMaskIntoConstraints = false
    siriButton.translatesAutoresizingMaskIntoConstraints = false

    self.view.addSubview(toolbar)
    toolbar.addSubview(siriButton)

    let blehorizontalConstraint = bleClientVC.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    let bleTopConstraint = bleClientVC.view.topAnchor.constraint(equalTo: view.topAnchor)
    let blewidthConstraint = bleClientVC.view.widthAnchor.constraint(equalTo: view.widthAnchor)
    let bleBottomConstraint = bleClientVC.view.bottomAnchor.constraint(equalTo: toolbar.topAnchor)
    NSLayoutConstraint.activate([blehorizontalConstraint, bleTopConstraint, bleBottomConstraint, blewidthConstraint])

    let toolbarHorizontalConstraint = toolbar.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    let toolbarBottomAnchor = toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    let toolbarWidthConstraint = toolbar.widthAnchor.constraint(equalTo: view.widthAnchor)
    let toolbarHeight = toolbar.heightAnchor.constraint(equalToConstant: 50)
    NSLayoutConstraint.activate([toolbarHorizontalConstraint, toolbarBottomAnchor,
                                 toolbarHeight, toolbarWidthConstraint])

    let siriButtonHConstraint = siriButton.centerXAnchor.constraint(equalTo: toolbar.centerXAnchor)
    let siriButtonVConstraint = siriButton.centerYAnchor.constraint(equalTo: toolbar.centerYAnchor)
    NSLayoutConstraint.activate([siriButtonHConstraint, siriButtonVConstraint])
  }

}
