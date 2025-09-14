//
//  TabBarExtensions.swift
//  midimittr
//
//  Created by Matthias Frick on 13/09/2019.
//  Copyright © 2019 Matthias Frick. All rights reserved.
//

import Foundation

extension UITabBarController {

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
          self.tabBar.tintColor = UIColor.DarkColors.tintColor
          if #available(iOS 26.0, *) { } else {
            self.tabBar.backgroundColor = UIColor.DarkColors.backgroundColor
          }
        }
        if userInterfaceStyle == .light {
          self.tabBar.tintColor = UIColor.LightColors.tintColor
          if #available(iOS 26.0, *) { } else {
            self.tabBar.backgroundColor = UIColor.LightColors.backgroundColor
          }
        }
    }
  }
}
