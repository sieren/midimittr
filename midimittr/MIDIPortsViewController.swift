//
//  MIDIPortsViewControllerTableViewController.swift
//  midimittr
//
//  Created by Matthias Frick on 27.12.2017.
//  Copyright © 2017 Matthias Frick. All rights reserved.
//

import UIKit

class MIDIPortsViewController: UIViewController, UITableViewDelegate,
                               UITableViewDataSource, MIDIControllerDelegate, MIDIPortCellDelegate {

  @IBOutlet weak var midiPortsTable: UITableView!
  var midiController: MIDIController!

  override func viewDidLoad() {
    super.viewDidLoad()
    self.midiPortsTable.delegate = self
    self.midiPortsTable.dataSource = self
    self.midiController.setMidiPortsDelegate(self)
    if #available(iOS 11.0, *) {
      self.midiPortsTable.insetsContentViewsToSafeArea = true
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: MIDIControllerDelegate

  func updateResources() {
    self.midiPortsTable.reloadData()
  }

  // MARK: TableView

  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return midiController.sources.count
    } else {
      return midiController.destinations.count
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch section {
    case 0:
      return "Sources"
    case 1:
      return "Destinations"
    default:
      fatalError("Invalid number of Sections")
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cellIdentifier = "Cell"
    var portName: String!
    var isOn: Bool = false

    switch indexPath.section {
    case 0:
      portName = midiController.sourceName(at: indexPath.row)
      isOn = midiController.selectSources.contains(midiController.sources.object(at: indexPath.row))
    case 1:
      portName = midiController.destinationName(at: indexPath.row)
      isOn = midiController.selectDestinations.contains(midiController.destinations.object(at: indexPath.row))
    default:
      fatalError("Invalid Section")
    }

    //swiftlint:disable:next force_cast
    let cell = (tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MIDIPortTableCell)
    cell.midiLabel?.text = portName
    cell.midiSwitch.isOn = isOn
    cell.delegate = self

    return cell
  }

  func didSwitch(for cell: UITableViewCell, value: Bool) {
    guard let indexPath = midiPortsTable.indexPath(for: cell) else { return }
    switch indexPath.section {
    case 0:
      midiController.didSelectSource(at: indexPath)
    case 1:
      midiController.didSelectDestination(at: indexPath)
    default:
      fatalError("Invalid Section")
    }
  }

  func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    //swiftlint:disable:next force_cast
    let header = view as! UITableViewHeaderFooterView
    let headerText = section == 0 ? "SOURCES" : "DESTINATIONS"
    header.textLabel?.text = headerText
  }
}
