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


internal class ObserverListController<Type>: ObserverControllerDelegate {

    // MARK: Type

    public typealias Observer = (Type) -> Void

    // MARK: Properties

    private var observerControllers: [ObserverController<Type>] = []
    private var active: Bool = false {
        didSet {
            if oldValue != active {
                if active {
                    self.delegate?.observerListDidActivate(self)
                } else {
                    self.delegate?.observerListDidDeactivate(self)
                }
            }
        }
    }

    public weak var delegate: ObserverListControllerDelegate?

    public var hasActiveObservers: Bool {
        let found = self.observerControllers.contains(where: { $0.active })
        return found
    }

    public var hasObservers: Bool {
        let empty = self.observerControllers.isEmpty
        return !empty
    }

    // MARK: ObserverControllerDelegate

    public func observerDidActivate<Type>(_ observer: ObserverController<Type>) {
        self.active = self.hasActiveObservers
    }

    public func observerDidDeactivate<Type>(_ observer: ObserverController<Type>) {
        self.active = self.hasActiveObservers
    }

    // MARK: ObserverListController (Adding and Removing Objects)

    public func insert(owner: LifecycleOwner, observer: @escaping Observer) -> ObserverController<Type> {
        tidyObserverControllers()

        let controller = ObserverController(owner: owner, observer: observer)
        controller.delegate = self
        self.observerControllers.append(controller)

        self.active = self.hasActiveObservers

        return controller
    }

    public func insert(observer: @escaping Observer) -> ObserverController<Type> {
        tidyObserverControllers()

        let controller = ObserverController(observer: observer)
        self.observerControllers.append(controller)

        self.active = self.hasActiveObservers

        return controller
    }

    public func remove(handle: ObserverHandle) {
        tidyObserverControllers()

        let remainingObservers = self.observerControllers.filter({ $0.handle != handle })
        self.observerControllers = remainingObservers

        self.active = self.hasActiveObservers
    }

    public func removeAllWithOwner(_ owner: LifecycleOwner) {
        tidyObserverControllers()

        let remainingObservers = self.observerControllers.filter({ !$0.hasOwner(owner) })
        self.observerControllers = remainingObservers

        self.active = self.hasActiveObservers
    }

    // MARK: ObserverListController (Notifying Observers)

    public func valueChanged(value: Type) {
        self.observerControllers.forEach { $0.valueChanged(value: value) }
    }

    // MARK: Private

    private func tidyObserverControllers() {
        // remove observers that have had their lifecycle owners released
        let remainingObservers = self.observerControllers.filter({ $0.forever || $0.owner != nil })
        self.observerControllers = remainingObservers
    }

}


internal protocol ObserverListControllerDelegate: class {
    func observerListDidActivate<Type>(_ list: ObserverListController<Type>)
    func observerListDidDeactivate<Type>(_ list: ObserverListController<Type>)
}
