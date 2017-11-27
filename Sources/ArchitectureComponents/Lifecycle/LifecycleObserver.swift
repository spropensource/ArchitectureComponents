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


/// Interface for receiving updates about changes to the state of a
/// `LifecycleOwner`.
///
/// The relationship between `LifecycleState` changes and observer callbacks:
///
///     initialized       destroyed       created       started       resumed
///          |                |              |             |             |
///          |-----------onCreate()--------->|             |             |
///          |                |              |--onStart()->|             |
///          |                |              |             |-onRresume()>|
///          |                |              |             |             |
///          |                |              |             |             |
///          |                |              |             |<-onPause()--|
///          |                |              |<--onStop()--|             |
///          |                |<-onDestroy()-|             |             |
///          |                |              |             |             |
public protocol LifecycleObserver: class {

    /// `LifecycleOwner` transitioned from INITIALIZED to CREATED
    func onCreate(owner: LifecycleOwner)

    /// `LifecycleOwner` transitioned from CREATED to STARTED
    func onStart(owner: LifecycleOwner)

    /// `LifecycleOwner` transitioned from STARTED to RESUMED
    func onResume(owner: LifecycleOwner)

    /// `LifecycleOwner` transitioned from RESUMED to STARTED
    func onPause(owner: LifecycleOwner)

    /// `LifecycleOwner` transitioned from STARTED to CREATED
    func onStop(owner: LifecycleOwner)

    /// `LifecycleOwner` transitioned from CREATED to DESTROYED
    func onDestroy(owner: LifecycleOwner)

}
