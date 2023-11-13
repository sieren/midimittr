//
//  midileactivityLiveActivity.swift
//  midileactivity
//
//  Created by Matthias Frick on 06.11.23.
//  Copyright © 2023 Matthias Frick. All rights reserved.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct MIDILiveActivity: Widget {
  @State private var selection: String?
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MIDIPortsAttributes.self) { context in
          HStack {
            Spacer()
            Image("mainIcon")
              .resizable()
              .frame(width: 50, height: 50)
            Spacer()
            VStack {
              Text("Sources").font(.caption)
              Text("\(context.state.connectedSources.count)")
            }
            Spacer()
            VStack {
              Image(systemName: "arrow.right")
            }
            Spacer()
            VStack {
              Text("Destinations").font(.caption)
              Text("\(context.state.connectedTargets.count)")
            }
            Spacer()
          }
          .frame(width: .infinity)
          .activityBackgroundTint(Color.cyan)
          .activitySystemActionForegroundColor(Color.black)
        } dynamicIsland: { context in
          DynamicIsland {
            DynamicIslandExpandedRegion(.leading) {
              Text("Sources")
              .font(.caption)
              .padding([.leading], 15)
            }
            DynamicIslandExpandedRegion(.trailing) {
              Text("Destinations")
                .font(.caption)
                .padding([.trailing], 15)
            }
            DynamicIslandExpandedRegion(.bottom) {
              HStack(alignment: .top) {
                VStack(alignment: .leading) {
                  if context.state.connectedSources.isEmpty {
                    Spacer().frame(maxWidth: .infinity, alignment: .leading)
                  }
                  ForEach(context.state.connectedSources.prefix(4), id: \.self) { source in
                    Text(source).font(.callout).frame(maxWidth: .infinity, alignment: .leading)
                  }
                }.padding([.leading], 15)

                VStack {
                  Image("activityIcon")
                }.frame(maxHeight: .infinity)

                VStack(alignment: .trailing) {
                  if context.state.connectedTargets.isEmpty {
                    Spacer().frame(maxWidth: .infinity, alignment: .leading)
                  }
                  ForEach(context.state.connectedTargets.prefix(4), id: \.self) { name in
                    Text(name).font(.callout).frame(maxWidth: .infinity, alignment: .trailing)
                  }
                }.padding([.trailing], 15)
              }
              if context.state.connectedSources.count > 4 ||
                  context.state.connectedTargets.count > 4 {
                Text("Open App to see more...")
                  .font(.footnote)
                  .frame(maxWidth: .infinity, alignment: .leading)
                  .padding([.leading], 15)
              }
            }
          } compactLeading: {
            Image("activityIcon")
          } compactTrailing: {
            HStack(spacing: 0) {
              Text("\(context.state.connectedSources.count)")
              Image(systemName: "arrow.right")
              Text("\(context.state.connectedTargets.count)")
            }
          } minimal: {
            Text("\(context.state.connectedTargets.count)")
          }
          .keylineTint(Color.red)
        }
    }
}

extension MIDIPortsAttributes {
    fileprivate static var preview: MIDIPortsAttributes {
      MIDIPortsAttributes()
    }
}

extension MIDIPortsAttributes.ContentState {
  fileprivate static var testPorts: MIDIPortsAttributes.ContentState {
    MIDIPortsAttributes.ContentState(
      connectedSources: ["Port A"],
      connectedTargets: ["Port B"]
    )
   }
}

#Preview("Notification", as: .content, using: MIDIPortsAttributes.preview) {
   MIDILiveActivity()
} contentStates: {
  MIDIPortsAttributes.ContentState.testPorts
}
