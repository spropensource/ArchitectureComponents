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

import XCTest
@testable import ArchitectureComponents


class LiveData_ObserverManagementTests: XCTestCase {
    
    func testInitialState() {
        // Action

        let liveData = MutableLiveData<Int>(initialValue: 0)

        // Assertions

        XCTAssertFalse(liveData.hasObservers)
        XCTAssertFalse(liveData.hasActiveObservers)
    }

    func testObserveForever() {
        // Setup

        let liveData = MutableLiveData<Int>(initialValue: 0)
        let mockObserver = MockLiveDataObserver<Int>()

        // Action

        let handle = liveData.observeForever(observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Assertions

        XCTAssertTrue(liveData.hasObservers)
        XCTAssertTrue(liveData.hasActiveObservers)
    }

    func testObserve_InactiveLifecycle() {
        // Setup

        let liveData = MutableLiveData<Int>(initialValue: 0)
        let mockObserver = MockLiveDataObserver<Int>()
        let lifecycleOwner = MockLifecycleOwner(initialState: .created)

        // Action

        let handle = liveData.observe(owner: lifecycleOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Assertions

        XCTAssertTrue(liveData.hasObservers)

        XCTAssertFalse(liveData.hasActiveObservers)
    }

    func testObserve_ActiveLifecycle() {
        // Setup

        let liveData = MutableLiveData<Int>(initialValue: 0)
        let mockObserver = MockLiveDataObserver<Int>()
        let lifecycleOwner = MockLifecycleOwner(initialState: .started)

        // Action

        let handle = liveData.observe(owner: lifecycleOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Assertions

        XCTAssertTrue(liveData.hasObservers)
        XCTAssertTrue(liveData.hasActiveObservers)
    }

    func testRemoveObserver() {
        // Setup

        let liveData = MutableLiveData<Int>(initialValue: 0)
        let mockObserver = MockLiveDataObserver<Int>()

        let handle = liveData.observeForever(observer: mockObserver.observer)

        // Action

        liveData.removeObserver(handle: handle)

        // Assertions

        XCTAssertFalse(liveData.hasObservers)
        XCTAssertFalse(liveData.hasActiveObservers)
    }

}
