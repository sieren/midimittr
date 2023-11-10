//
//  ActivityAttributes.swift
//  midimittr
//
//  Created by Matthias Frick on 06.11.23.
//  Copyright © 2023 Matthias Frick. All rights reserved.
//

import Foundation


#if canImport(ActivityKit)

import ActivityKit

struct MIDIPortsAttributes: ActivityAttributes {
    struct ContentState: Codable & Hashable {
        let connectedSources: [String]
        let connectedTargets: [String]
    }
}

#endif
