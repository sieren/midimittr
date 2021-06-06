//  Copyright © 2017 Matthias Frick. All rights reserved.

import UIKit

protocol MIDIPortCellDelegate: class {
  func didSwitch(for cell: UITableViewCell, value: Bool)
}

class MIDIPortTableCell: UITableViewCell {

  weak var delegate: MIDIPortCellDelegate?
  @IBOutlet weak var midiSwitch: UISwitch!
  @IBOutlet weak var midiLabel: UILabel!

  override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
  }

  @IBAction func didChangeValue(_ sender: UISwitch) {
    delegate?.didSwitch(for: self, value: midiSwitch.isOn)
    if #available(iOS 10.0, *) {
      let generator = UIImpactFeedbackGenerator(style: .light)
      generator.impactOccurred()
    }
  }

}
