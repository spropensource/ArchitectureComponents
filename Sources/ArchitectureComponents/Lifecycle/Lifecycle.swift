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


/// Defines an object that has an Android Lifecycle.
///
/// A `Lifecycle` has the following states and events:
///
///     initialized       destroyed       created       started       resumed
///          |                |              |             |             |
///          |-------------create----------->|             |             |
///          |                |              |----start--->|             |
///          |                |              |             |---resume--->|
///          |                |              |             |             |
///          |                |              |             |             |
///          |                |              |             |<---pause----|
///          |                |              |<----stop----|             |
///          |                |<---destroy---|             |             |
///          |                |              |             |             |
public protocol Lifecycle {

    var currentState: LifecycleState { get }

    /// Adds a `LifecycleObserver` that will be notified when the
    /// `LifecycleOwner` changes state.
    ///
    /// Attempting to add the same observer multiple times will not cause the
    /// observer to be notified multiple times when the `LifecycleOwner`
    /// changes state
    func addObserver(_ observer: LifecycleObserver)

    /// Removes the provided observer from the observers list. The observer
    /// will no longer be notified when the `LifecycleOwner` changes state.
    ///
    /// Attempting to remove an observer that is not in the observers list
    /// does nothing.
    func removeObserver(_ observer: LifecycleObserver)

}

public enum LifecycleEvent {

    case create
    case start
    case resume
    case pause
    case stop
    case destroy

    // MARK: Types

    public typealias Handler = (LifecycleEvent) -> Void

}

public enum LifecycleState: Int {

    case initialized = 0
    case created = 2
    case started = 3
    case resumed = 4
    case destroyed = 1

}
