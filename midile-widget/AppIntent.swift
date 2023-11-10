//
//  AppIntent.swift
//  midile-widget
//
//  Created by Matthias Frick on 29.10.23.
//  Copyright © 2023 Matthias Frick. All rights reserved.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget.")

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
