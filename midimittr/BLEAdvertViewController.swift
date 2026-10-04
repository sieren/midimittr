//  Copyright © 2017 Matthias Frick. All rights reserved.

import UIKit
import CoreAudioKit
import CoreBluetooth

/// Wraps Apple's `CABTMIDILocalPeripheralViewController`, which is the only way
/// to start/stop BLE MIDI advertising and has no public API for its state.
/// Apple's controller does not remember the setting, so this subclass persists
/// the user's choice and, once CoreBluetooth reports `.poweredOn`, re-applies it
/// by driving the controller's own UISwitch.
class BLEAdvertViewController: CABTMIDILocalPeripheralViewController, CBPeripheralManagerDelegate {

  static let advertisingKey = "advertisingEnabled"

  private var stateObserver: CBPeripheralManager?
  private var restorePending = false
  private var searchAttempts = 0
  private weak var advertSwitch: UISwitch?

  /// Loads the view hierarchy (tab bar controllers only load the selected tab)
  /// and starts waiting for Bluetooth so the saved state can be restored.
  func restoreAdvertisingIfNeeded() {
    guard UserDefaults.standard.bool(forKey: BLEAdvertViewController.advertisingKey) else { return }
    loadViewIfNeeded()
    restorePending = true
    if stateObserver == nil {
      stateObserver = CBPeripheralManager(delegate: self, queue: .main,
                                          options: [CBPeripheralManagerOptionShowPowerAlertKey: false])
    }
    attemptRestore()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    attachToSwitch()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController!.navigationBar.topItem?.title = "Bluetooth Advertising"
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    attachToSwitch()
    attemptRestore()
  }

  // MARK: CBPeripheralManagerDelegate

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    attemptRestore()
  }

  // MARK: Restore

  private func attemptRestore() {
    guard restorePending, stateObserver?.state == .poweredOn else { return }
    attachToSwitch()
    guard let toggle = advertSwitch else {
      // The switch lives in a lazily built (private) hierarchy; retry shortly.
      searchAttempts += 1
      if searchAttempts <= 20 {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in self?.attemptRestore() }
      } else {
        NSLog("midimittr: could not find advertising switch; advertising not restored")
      }
      return
    }
    restorePending = false
    if !toggle.isOn {
      toggle.setOn(true, animated: false)
      toggle.sendActions(for: .valueChanged)
    }
  }

  // MARK: Persistence

  private func attachToSwitch() {
    guard advertSwitch == nil, isViewLoaded else { return }
    view.layoutIfNeeded()
    guard let toggle = BLEAdvertViewController.findSwitch(in: view) else { return }
    advertSwitch = toggle
    // .primaryActionTriggered fires for user taps only, not for the
    // programmatic sendActions(.valueChanged) used when restoring.
    toggle.addTarget(self, action: #selector(userToggledAdvertising(_:)), for: .primaryActionTriggered)
  }

  @objc private func userToggledAdvertising(_ sender: UISwitch) {
    UserDefaults.standard.set(sender.isOn, forKey: BLEAdvertViewController.advertisingKey)
  }

  private static func findSwitch(in root: UIView) -> UISwitch? {
    if let toggle = root as? UISwitch { return toggle }
    for sub in root.subviews {
      if let found = findSwitch(in: sub) { return found }
    }
    return nil
  }
}
