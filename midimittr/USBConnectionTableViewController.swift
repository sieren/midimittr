//  Copyright © 2017 Matthias Frick. All rights reserved.

import UIKit

class USBConnectionTableViewController: UITableViewController {

  @objc var peerTalkBridge: PeerTalkBridge!
  static private let cellIdentifier = "USB"

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    peerTalkBridge.addObserver(self, forKeyPath: "connectionState", options: .new, context: nil)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
    cell?.textLabel?.text = peerTalkBridge.connectionState.description
    if #available(iOS 11.0, *) { } else { // Fix missing Safe-Area on iOS < 11
      if let rect = self.navigationController?.navigationBar.frame {
        let y = rect.size.height + rect.origin.y
        tableView.contentInset = UIEdgeInsets(top: y, left: 0, bottom: 0, right: 0)
      }
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: USBConnectionTableViewController.cellIdentifier)
    cell?.textLabel?.text = peerTalkBridge.connectionState.description
    return cell!
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "USB Connection State"
  }

  override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    return String()
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 44
  }

  override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
    //swiftlint:disable:next force_cast
    let footer = view as! UITableViewHeaderFooterView
    let footerText = "TO USE MIDI OVER LIGHTNING CABLE, GET THE MIDIMITTR DESKTOP APP FROM S-R-N.DE/MIDIMITTR"
    let footerAttrText = NSMutableAttributedString(string: footerText)
    footerAttrText.addAttribute(.link, value: "http://www.s-r-n.de/midimittr", range: NSRange(location: 68, length: 19))
    let textView = UITextView(frame: footer.contentView.frame)
    textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 0, right: 0)
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.isEditable = false
    textView.backgroundColor = .clear
    textView.isSelectable = true
    textView.attributedText = footerAttrText
    textView.textColor = .gray
    footer.contentView.addSubview(textView)
    let horizontalConstraint = textView.centerXAnchor.constraint(equalTo: footer.contentView.centerXAnchor)
    let verticalConstraint = textView.centerYAnchor.constraint(equalTo: footer.contentView.centerYAnchor)
    let widthConstraint = textView.widthAnchor.constraint(equalTo: footer.contentView.widthAnchor)
    let heightConstraint = textView.heightAnchor.constraint(equalToConstant: 44)
    NSLayoutConstraint.activate([widthConstraint, horizontalConstraint, verticalConstraint, heightConstraint])
  }

  //swiftlint:disable:next block_based_kvo
  override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                             change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "connectionState" {
      let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
      cell?.textLabel?.text = peerTalkBridge.connectionState.description
    }
  }
}

extension ConnectionState {
  var description: String! {
    switch self {
    case .disconnected:
      return "Disconnected"
    case .connected:
      return "Connected"
    case .disabled:
      return "USB Disabled"
    }
  }
}
