//  Copyright © 2023 Matthias Frick. All rights reserved.

import Foundation


#if canImport(ActivityKit)

import ActivityKit
#endif

@available(iOS 16.2, *)
public class ActivityViewHandler: MIDIControllerDelegate {
 

  struct ActivityViewState: Sendable {
    var activityState: ActivityState
    var contentState: MIDIPortsAttributes.ContentState
    var pushToken: String? = nil
    
    var shouldShowEndControls: Bool {
      switch activityState {
      case .active, .stale:
        return true
      case .ended, .dismissed:
        return false
      @unknown default:
        return false
      }
    }
  }

  var midiController: MIDIController!
  var activityViewState: ActivityViewState? = nil
  private var currentActivity: Activity<MIDIPortsAttributes>? = nil
  private var timer: Timer?

  private var contentState: MIDIPortsAttributes.ContentState {
    var sources: [String] = []
    for src in midiController.selectSources as! Set<PGMidiSource> {
      sources.append(src.name)
    }
    var destinations: [String] = []
    for dst in midiController.selectDestinations as! Set<PGMidiDestination> {
      destinations.append(dst.name)
    }
    return MIDIPortsAttributes.ContentState(
      connectedSources: sources,
      connectedTargets: destinations
    )
  }

  public init(midiController: MIDIController) {
    self.midiController = midiController
    self.midiController.setActivityViewDelegate(self)
  }

  public func updateResources() {
    if activityViewState == nil {
      start()
      return
    }
    guard let activity = currentActivity else { return }
    let newState = contentState
    Task.detached { @MainActor in
      await activity.update(using: self.contentState)
    }
  }

  public func start() {
    if !ActivityAuthorizationInfo().areActivitiesEnabled { return }
  
    do {
      let connectionState = MIDIPortsAttributes()
      
      let activity = try Activity.request(
        attributes: connectionState,
        content: .init(state: contentState, staleDate: nil)
      )
      
      self.activityViewState = .init(
        ActivityViewState(
          activityState: activity.activityState,
          contentState: activity.content.state
        )
      )
      self.currentActivity = activity
      observeActivity(activity: activity)
    } catch {
      print(error.localizedDescription)
    }
  
  }

  func observeActivity(activity: Activity<MIDIPortsAttributes>) {
    Task {
      await withTaskGroup(of: Void.self) { group in
        group.addTask { @MainActor in
          for await activityState in activity.activityStateUpdates {
            if activityState == .dismissed {
              self.cleanUpDismissedActivity()
            } else {
              self.activityViewState?.activityState = activityState
            }
          }
        }
      }
    }
  }

  
  func cleanUpDismissedActivity() {
    self.currentActivity = nil
    self.activityViewState = nil
  }
}
