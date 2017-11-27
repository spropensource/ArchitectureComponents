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


internal class SwitchedLiveData<InType, OutType>: LiveData<OutType> {

    // MARK: Properties

    private var sourceHandle: ObserverHandle?
    private var source: LiveData<OutType>
    private let transform: (InType) -> LiveData<OutType>
    private let trigger: LiveData<InType>
    private var triggerHandle: ObserverHandle?

    // MARK: Init / Deinit

    internal init(trigger: LiveData<InType>, transform: @escaping (InType) -> LiveData<OutType>) {
        let initialInValue = trigger.value
        let initialOutLiveData = transform(initialInValue)
        let initialOutValue = initialOutLiveData.value

        self.sourceHandle = nil
        self.source = initialOutLiveData
        self.transform = transform
        self.trigger = trigger
        self.triggerHandle = nil

        super.init(initialValue: initialOutValue)

        // Written using a block instead of a method reference so that
        // reference to `self` is weak.
        self.triggerHandle = self.trigger.observeForever { [weak self] (inValue) in
            self?.createAndObserverNextLiveData(inValue: inValue)
        }

        // Start observing self.source
        self.createAndObserverNextLiveData(inValue: initialInValue)
    }

    deinit {
        if let sourceHandle = self.sourceHandle {
            self.source.removeObserver(handle: sourceHandle)
        }
        if let triggerHandle = self.triggerHandle {
            self.trigger.removeObserver(handle: triggerHandle)
        }
    }

    // MARK: Private

    private func createAndObserverNextLiveData(inValue: InType) {
        // Create the next LiveData<OutType>.
        //
        // To avoid re-creating the first LiveData<OutType> that is generated
        // by the initializer, this section checks if sourceHandle is set
        // before creating a new LiveData. This may be a Premature
        // Optimization.
        if let handle = self.sourceHandle {
            // Stop observing the current LiveData<OutType>
            self.source.removeObserver(handle: handle)

            // Create the next LiveData<OutType>, overwriting the current one
            self.source = self.transform(inValue)
        }

        // Update this LiveData's value whenever the new LiveData<OutType>
        // updates itself
        self.sourceHandle = self.source.observeForever { [weak self] (outValue) in
            self?.value = outValue
        }
    }

}
