//  Copyright © 2019 Matthias Frick. All rights reserved.

import Foundation

extension UINavigationController {
  override open func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    updateAppearance()
  }

  override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    updateAppearance()
  }

  private func updateAppearance() {
    if #available(iOS 12.0, *) {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        if userInterfaceStyle == .dark {
          self.navigationBar.tintColor = UIColor.DarkColors.tintColor
          self.self.navigationBar.backgroundColor = UIColor.DarkColors.backgroundColor
        }
        if userInterfaceStyle == .light {
          self.navigationBar.tintColor = UIColor.LightColors.tintColor
          self.self.navigationBar.backgroundColor = UIColor.LightColors.backgroundColor
        }
    }
  }
}
