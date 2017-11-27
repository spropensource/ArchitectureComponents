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


internal class ObserverController<Type>: LifecycleObserver {

    // MARK: Types

    public typealias Observer = (Type) -> Void

    private indirect enum ObservedValue {
        case empty
        case filled(Type)
    }

    // MARK: Properties

    public let handle: ObserverHandle
    public let forever: Bool

    private let observer: Observer

    public weak var delegate: ObserverControllerDelegate?

    public weak var owner: LifecycleOwner?

    private var lastObservedValue: ObservedValue
    private var nextObservedValue: ObservedValue

    public var active: Bool {
        // Forever observers are always active
        guard !self.forever else { return true }
        // If the owner has been released, then this observer is not active
        guard let owner = self.owner else { return false }

        let active: Bool
        switch owner.lifecycle.currentState {
        case .started, .resumed: active = true
        default: active = false
        }
        return active
    }

    // MARK: Init / Deinit

    public init(owner: LifecycleOwner, observer: @escaping Observer) {
        let observerObject = observer as AnyObject
        let handleValue = ObjectIdentifier(observerObject)

        self.handle = ObserverHandle(value: handleValue)
        self.owner = owner
        self.observer = observer
        self.forever = false

        self.lastObservedValue = .empty
        self.nextObservedValue = .empty

        owner.lifecycle.addObserver(self)
    }

    public init(observer: @escaping Observer) {
        let observerObject = observer as AnyObject
        let handleValue = ObjectIdentifier(observerObject)

        self.handle = ObserverHandle(value: handleValue)
        self.owner = nil
        self.observer = observer
        self.forever = true

        self.lastObservedValue = .empty
        self.nextObservedValue = .empty
    }

    deinit {
        self.owner?.lifecycle.removeObserver(self)
    }

    // MARK: LifecycleObserver

    public func onCreate(owner: LifecycleOwner) { }

    public func onStart(owner: LifecycleOwner) {
        self.delegate?.observerDidActivate(self)

        // Written this way instead of with "if case .filled(...)" to
        // handle nil values properly.
        switch self.nextObservedValue {
        case .empty: break
        case .filled(let nextValue):
            notifyObserverIfChanged(value: nextValue)
        }
    }

    public func onResume(owner: LifecycleOwner) { }

    public func onPause(owner: LifecycleOwner) { }

    public func onStop(owner: LifecycleOwner) {
        self.delegate?.observerDidDeactivate(self)
    }

    public func onDestroy(owner: LifecycleOwner) {
        owner.lifecycle.removeObserver(self)
        self.owner = nil
    }

    // MARK: ObserverController

    public func hasOwner(_ owner: LifecycleOwner) -> Bool {
        guard let myOwner = self.owner else { return false }
        let sameOwner = (myOwner === owner)
        return sameOwner
    }

    public func valueChanged(value: Type) {
        if self.active {
            self.notifyObserverIfChanged(value: value)
        } else {
            self.nextObservedValue = .filled(value)
        }
    }

    // MARK: Private

    private func notifyObserverIfChanged(value nextValue: Type) {
        switch self.lastObservedValue {
        case .empty:
            self.notifyObserver(value: nextValue)
        case .filled(let lastValue):
            let changed = !self.equal(last: lastValue, next: nextValue)
            if changed {
                self.notifyObserver(value: nextValue)
            }
        }
    }

    private func notifyObserver(value: Type) {
        self.lastObservedValue = .filled(value)
        self.nextObservedValue = .empty
        self.observer(value)
    }

    // Private (Comparison)

    private func equal<EquatableType>(last: EquatableType?, next: EquatableType?) -> Bool where EquatableType: Equatable {
        let result: Bool

        if let last = last, let next = next {
            result = (last == next)
        } else if last == nil && next == nil {
            result = true
        } else {
            result = false
        }

        return result
    }

    private func equal(last: Type, next: Type) -> Bool {
        let lastObject = last as AnyObject?
        let nextObject = next as AnyObject?

        let result = (lastObject === nextObject)
        return result
    }

}

internal protocol ObserverControllerDelegate: class {
    func observerDidActivate<Type>(_ observer: ObserverController<Type>)
    func observerDidDeactivate<Type>(_ observer: ObserverController<Type>)
}
