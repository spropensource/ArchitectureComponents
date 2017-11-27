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


internal class TransformedLiveData<InType, OutType>: LiveData<OutType> {

    // MARK: Properties

    private let source: LiveData<InType>
    private var sourceHandle: ObserverHandle?
    private let transform: (InType) -> OutType

    // MARK: Init / Deinit

    internal init(source: LiveData<InType>, transform: @escaping (InType) -> OutType) {
        self.source = source
        self.sourceHandle = nil
        self.transform = transform

        let initialValueIn = source.value
        let initialValueOut = transform(initialValueIn)
        super.init(initialValue: initialValueOut)

        self.sourceHandle = source.observeForever { [weak self] (inValue) in
            guard let strongSelf = self else { return }

            let outValue = strongSelf.transform(inValue)
            strongSelf.value = outValue
        }
    }

    deinit {
        if let sourceHandle = self.sourceHandle {
            self.source.removeObserver(handle: sourceHandle)
        }
    }

}
