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


/// Generally, `LiveData` delivers updates only when data changes, and only to
/// active observers. An exception to this behavior is that observers also
/// receive an update when they change from an inactive to an active state.
/// Furthermore, if the observer changes from inactive to active a second time,
/// it only receives an update if the value has changed since the last time it
/// became active.
open class LiveData<Type> {

    // MARK: Types

    public typealias Observer = (Type) -> Void

    // MARK: Properties

    public internal(set) var value: Type

    // MARK: Init / Deinit

    public init(initialValue: Type) {
        self.value = initialValue
    }

    // MARK: LiveData

    public var hasObservers: Bool {
        return false
    }

    public var hasActiveObservers: Bool {
        return false
    }

    public func observe(owner: LifecycleOwner, observer: @escaping Observer) -> ObserverHandle {
        fatalError("LiveData.observe(owner:observer:) should have override")
    }

    public func observeForever(observer: @escaping Observer) -> ObserverHandle {
        fatalError("LiveData.observeForever(observer:) should have override")
    }

    public func removeObserver(handle: ObserverHandle) {
        fatalError("LiveData.removeObserver(handle:) should have override")
    }

    public func removeObservers(owner: LifecycleOwner) {
        fatalError("LiveData.removeObservers(owner:) should have override")
    }

}
