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


/// LiveData subclass that exposes methods for updating the value.  
open class MutableLiveData<Type>: LiveData<Type>, ObserverListControllerDelegate {

    // MARK: Types

    private indirect enum ValueHolder {
        case empty
        case filled(Type)
    }

    // MARK: Properties

    public override var value: Type {
        willSet {
            assert(Thread.isMainThread)
        }
        didSet {
            self.controller.valueChanged(value: self.value)
        }
    }

    private var nextValue: ValueHolder
    private let semaphore: DispatchSemaphore

    private let controller: ObserverListController<Type>

    // MARK: Init / Deinit

    public override init(initialValue: Type) {
        self.controller = ObserverListController<Type>()
        self.nextValue = .empty
        self.semaphore = DispatchSemaphore(value: 1)

        super.init(initialValue: initialValue)

        self.controller.delegate = self
    }

    // MARK: LiveData

    public override var hasObservers: Bool {
        assert(Thread.isMainThread)
        return self.controller.hasObservers
    }

    public override var hasActiveObservers: Bool {
        assert(Thread.isMainThread)
        return self.controller.hasActiveObservers
    }

    public override func observe(owner: LifecycleOwner, observer: @escaping Observer) -> ObserverHandle {
        assert(Thread.isMainThread)
        let observerController = self.controller.insert(owner: owner, observer: observer)
        return observerController.handle
    }

    public override func observeForever(observer: @escaping Observer) -> ObserverHandle {
        assert(Thread.isMainThread)
        let observerController = self.controller.insert(observer: observer)
        return observerController.handle
    }

    public override func removeObserver(handle: ObserverHandle) {
        assert(Thread.isMainThread)
        self.controller.remove(handle: handle)
    }

    public override func removeObservers(owner: LifecycleOwner) {
        assert(Thread.isMainThread)
        self.controller.removeAllWithOwner(owner)
    }

    // MARK: ObserverListControllerDelegate

    internal final func observerListDidActivate<T>(_ list: ObserverListController<T>) {
        self.onActive()
    }

    internal final func observerListDidDeactivate<T>(_ list: ObserverListController<T>) {
        self.onInactive()
    }

    // MARK: MutableLiveData

    // TODO: write tests for this function
    open func onActive() { }

    // TODO: write tests for this function
    open func onInactive() { }

    public final func postValue(_ value: Type) {
        self.semaphore.wait()
        self.nextValue = .filled(value)
        self.semaphore.signal()

        DispatchQueue.main.async {
            self.semaphore.wait()
            let nextValue = self.nextValue
            self.semaphore.signal()

            // Using switch instead of `if case .filled(let latestValue)` to
            // handle the case when Type is optional and the value is nil.
            switch nextValue {
            case .empty: break
            case .filled(let latestValue):
                self.value = latestValue
            }
        }
    }

}
