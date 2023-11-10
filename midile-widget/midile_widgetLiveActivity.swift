//
//  midile_widgetLiveActivity.swift
//  midile-widget
//
//  Created by Matthias Frick on 29.10.23.
//  Copyright © 2023 Matthias Frick. All rights reserved.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct midile_widgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct midile_widgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: midile_widgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension midile_widgetAttributes {
    fileprivate static var preview: midile_widgetAttributes {
        midile_widgetAttributes(name: "World")
    }
}

extension midile_widgetAttributes.ContentState {
    fileprivate static var smiley: midile_widgetAttributes.ContentState {
        midile_widgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: midile_widgetAttributes.ContentState {
         midile_widgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: midile_widgetAttributes.preview) {
   midile_widgetLiveActivity()
} contentStates: {
    midile_widgetAttributes.ContentState.smiley
    midile_widgetAttributes.ContentState.starEyes
}
