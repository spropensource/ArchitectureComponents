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


class MockLifecycleOwner: LifecycleOwner {

    // MARK: Properties

    private let initialState: LifecycleState

    private lazy var registry: LifecycleRegistry = LifecycleRegistry(
        provider: self,
        initialState: self.initialState
    )

    // MARK: Init / Deinit

    init(initialState: LifecycleState) {
        self.initialState = initialState
    }

    // MARK: LifecycleOwner

    public var lifecycle: Lifecycle { return self.registry }

    // MARK: MockLifecycleOwner

    func transitionToState(_ state: LifecycleState) {
        self.registry.markState(state)
    }
    
}
