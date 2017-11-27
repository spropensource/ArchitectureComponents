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


open class MediatorLiveData<Type>: MutableLiveData<Type> {
    // TODO: write tests for this class

    // MARK: Properties

    private var active: Bool = false
    private var handlesBySource: [ObjectIdentifier: ObserverHandle] = [:]

    // MARK: LiveData

    open override func onActive() {
        self.active = true
    }

    open override func onInactive() {
        self.active = false
    }

    // MARK: MutableLiveData (Public)

    public func addSource(_ source: LiveData<Type>, observer: @escaping Observer) throws {
        let sourceIdentifier = ObjectIdentifier(source)
        guard self.handlesBySource[sourceIdentifier] == nil else {
            throw LiveDataError.sourceAlreadyAddedToMediator
        }

        let handle = source.observeForever { [weak self] (value) in
            guard
                let active = self?.active,
                active
            else { return }

            observer(value)
        }

        self.handlesBySource[sourceIdentifier] = handle
    }

    public func removeSource(_ source: LiveData<Type>) {
        let sourceIdentifier = ObjectIdentifier(source)
        guard let handle = self.handlesBySource[sourceIdentifier] else { return }

        source.removeObserver(handle: handle)
    }

    // MARK: MutableLiveData (Internal)

    internal func removeAllSources() {
        for handle in self.handlesBySource.values {
            self.removeObserver(handle: handle)
        }
    }

}
