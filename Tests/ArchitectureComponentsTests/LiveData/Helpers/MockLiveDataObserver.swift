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

import ArchitectureComponents


class MockLiveDataObserver<Type> {
    
    /// Used by tests to check the sequence of values sent to this class.
    var valuesObserved: [Type] = []

    /// Used to register this class as an observer on a LiveData object.
    ///
    /// Example:
    ///
    ///     let liveData = LiveData<Int>
    ///     let mockObserver = MockLiveDataObserver<Int>
    ///     liveData.observe(mockObserver.observer)
    var observer: LiveData<Type>.Observer {
        return self.onChange(value:)
    }

    /// Internal implementation of LiveData.Observer type.
    private func onChange(value: Type) {
        self.valuesObserved.append(value)
    }

}
