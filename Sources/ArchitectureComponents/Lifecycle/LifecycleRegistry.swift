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


/// Implementation of `Lifecycle` that allows the `LifecycleOwner` to notify
/// observers of state changes.
public class LifecycleRegistry: Lifecycle {
    // TODO: write tests for this class

    // MARK: Types

    /// Envelope that holds a weak reference to a `LifecycleObserver` and provides
    /// additional capabilities useful to `LifecycleRegistry`.
    private class LifecycleObserverEnvelope: Equatable, Hashable {

        // MARK: Equatable

        public static func ==(lhs: LifecycleObserverEnvelope, rhs: LifecycleObserverEnvelope) -> Bool {
            return (lhs.lifecycleObserver === rhs.lifecycleObserver)
        }

        // MARK: Properties

        public private(set) weak var lifecycleObserver: LifecycleObserver?

        // MARK: init / deinit

        public init(observer: LifecycleObserver) {
            self.lifecycleObserver = observer
        }

        // MARK: Hashable

        public var hashValue: Int {
            guard let observer = self.lifecycleObserver else { return 0 }

            let hashed = ObjectIdentifier(observer).hashValue
            return hashed
        }

    }

    // MARK: Properties

    // It is possible for another object to hold a reference to this Lifecycle
    // long after this Lifecycle's owner has been disposed. Therefore, we need
    // a weak reference, not an unowned reference.
    private weak var owner: LifecycleOwner?

    private var weakObservers: Set<LifecycleObserverEnvelope> = []

    // MARK: Init / Deinit

    public convenience init(provider: LifecycleOwner) {
        self.init(provider: provider, initialState: .initialized)
    }

    public init(provider: LifecycleOwner, initialState: LifecycleState) {
        self.currentState = initialState
        self.owner = provider
    }

    // MARK: Lifecycle

    public private(set) var currentState: LifecycleState

    public func addObserver(_ observer: LifecycleObserver) {
        assert(Thread.isMainThread)

        // take the opportunity to remove any observers that have been
        // deallocated
        self.cleanupObservers()

        // add the provided observer to the list of observers
        let weakObserver = LifecycleObserverEnvelope(observer: observer)
        self.weakObservers.insert(weakObserver)
    }

    /// Thread-safe, since it common for this method to be called from a
    /// type's `deinit`, which can be called from any thread.
    public func removeObserver(_ observer: LifecycleObserver) {
        let runIt = {
            // take the opportunity to remove any observers that have been
            // deallocated
            self.cleanupObservers()

            // remove the provided observer from the list of observers
            let weakObserver = LifecycleObserverEnvelope(observer: observer)
            self.weakObservers.remove(weakObserver)
        }

        if Thread.isMainThread {
            runIt()
        } else {
            DispatchQueue.main.async(execute: runIt)
        }
    }

    // MARK: LifecycleRegistry

    public var observerCount: Int {
        assert(Thread.isMainThread)

        cleanupObservers()

        let count = self.weakObservers.count
        return count
    }

    public func handleLifecycleEvent(_ event: LifecycleEvent, beforeObservers handler: LifecycleEvent.Handler? = nil) {
        assert(Thread.isMainThread)

        // Update properties FIRST, THEN notify everyone of the change.
        self.currentState = event.stateAfter

        // Notify event handler BEFORE notifying observers. This is used by
        // LifecycleViewController to call its own onCreate(), onStart(), etc.
        // before the observers start doing their work.
        if let handler = handler {
            handler(event)
        }

        // Notify the observers
        self.notifyObserversOfEvent(event)
    }

    public func markState(_ targetState: LifecycleState, beforeObservers handler: LifecycleEvent.Handler? = nil) {
        assert(Thread.isMainThread)

        // determine the steps required to transition from current state to the
        // target state
        guard let events = try? self.currentState.eventsToState(targetState) else { return }

        // update the lifecycle's state to each state required to transition
        // from the current state to the target state
        for event in events {
            self.handleLifecycleEvent(event, beforeObservers: handler)
        }
    }

    // MARK: Private (Observers)

    private func cleanupObservers() {
        let remainingObservers = self.weakObservers.filter({ $0.lifecycleObserver != nil })
        self.weakObservers = remainingObservers
    }

    private func notifyObserversOfEvent(_ event: LifecycleEvent) {
        guard let owner = self.owner else { return }

        let activeObservers = self.weakObservers.compactMap({ $0.lifecycleObserver })
        for observer in activeObservers {
            switch event {
            case .create:  observer.onCreate(owner: owner)
            case .start:   observer.onStart(owner: owner)
            case .resume:  observer.onResume(owner: owner)
            case .pause:   observer.onPause(owner: owner)
            case .stop:    observer.onStop(owner: owner)
            case .destroy: observer.onDestroy(owner: owner)
            }
        }
    }

}
