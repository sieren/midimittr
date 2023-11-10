//  Copyright © 2023 Matthias Frick. All rights reserved.

import Foundation

func isiOSAppOnMac() -> Bool {
  if #available(iOS 14.0, *) {
    return ProcessInfo.processInfo.isiOSAppOnMac
  }
  return false
}

