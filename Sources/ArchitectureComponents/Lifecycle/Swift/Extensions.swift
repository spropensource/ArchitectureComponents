// ArchitectureComponents
// Copyright (c) 2017 SPRI, LLC <info@spr.com>. Some rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation


extension LifecycleError: CustomStringConvertible {

    public var description: String {
        let string: String
        switch self {
        case let .invalidStateTransition(from: f, to: t):
            string = "Invalid state transition from \(f) to \(t)"
        case let .invalidEventForState(state: s, event: e):
            string = "Invalid event \(e) while in state \(s)"
        }
        return string
    }

}


extension LifecycleEvent: CustomStringConvertible {

    // MARK: CustomStringConvertible

    public var description: String {
        let string: String

        switch self {
        case .create:  string = "CREATE"
        case .start:   string = "START"
        case .resume:  string = "RESUME"
        case .pause:   string = "PAUSE"
        case .stop:    string = "STOP"
        case .destroy: string = "DESTROY"
        }

        return string
    }

}

internal extension LifecycleEvent {

    // MARK: Helpers

    internal var stateAfter: LifecycleState {
        let state: LifecycleState
        switch self {
        case .create:  state = .created
        case .start:   state = .started
        case .resume:  state = .resumed
        case .pause:   state = .started
        case .stop:    state = .created
        case .destroy: state = .destroyed
        }
        return state
    }

    internal var stateBefore: LifecycleState {
        let state: LifecycleState
        switch self {
        case .create:  state = .initialized
        case .start:   state = .created
        case .resume:  state = .started
        case .pause:   state = .resumed
        case .stop:    state = .started
        case .destroy: state = .created
        }
        return state
    }

}

extension LifecycleState: Comparable, CustomStringConvertible {

    public static func <(lhs: LifecycleState, rhs: LifecycleState) -> Bool {
        let comp = lhs.rawValue < rhs.rawValue
        return comp
    }

    public var description: String {
        let string: String
        switch self {
        case .initialized: string = "INITIALIZED"
        case .created:     string = "CREATED"
        case .started:     string = "STARTED"
        case .resumed:     string = "RESUMED"
        case .destroyed:   string = "DESTROYED"
        }
        return string
    }
}

internal extension LifecycleState {

    internal func eventsToState(_ targetState: LifecycleState) throws -> [LifecycleEvent] {
        guard self != targetState else { return [] }
        guard targetState != .initialized else {
			throw LifecycleError.invalidStateTransition(from: self, to: targetState)
        }

        let event: LifecycleEvent?
        if self < targetState {
            event = self.eventToAdvanceState
        } else {
            event = self.eventToRetreatState
        }

        guard let nextEvent = event else {
            throw LifecycleError.invalidStateTransition(from: self, to: targetState)
        }

        let trailingEvents = try nextEvent.stateAfter.eventsToState(targetState)
        let events = [nextEvent] + trailingEvents  // TODO: maybe use .insert(_:at:) ?
        return events
    }

    private var eventToAdvanceState: LifecycleEvent? {
        let event: LifecycleEvent?
		switch self {
		case .initialized: event = .create
		case .created: event = .start
		case .started: event = .resume
		default: event = nil
		}
		return event
    }

    private var eventToRetreatState: LifecycleEvent? {
        let event: LifecycleEvent?
		switch self {
		case .created: event = .destroy
		case .started: event = .stop
		case .resumed: event = .pause
		default: event = nil
		}
		return event
    }

}
