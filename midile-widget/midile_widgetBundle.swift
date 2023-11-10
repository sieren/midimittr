//
//  midile_widgetBundle.swift
//  midile-widget
//
//  Created by Matthias Frick on 29.10.23.
//  Copyright © 2023 Matthias Frick. All rights reserved.
//

import WidgetKit
import SwiftUI

@main
struct midile_widgetBundle: WidgetBundle {
    var body: some Widget {
        midile_widget()
        midile_widgetLiveActivity()
    }
}
