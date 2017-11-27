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


class LiveData_NotificationTests: XCTestCase {
    
    func testForeverObserverNotifiedOnEveryChange() {
        // Setup
        let liveData = MutableLiveData<Int?>(initialValue: -1)
        let mockObserver = MockLiveDataObserver<Int?>()
        let handle = liveData.observeForever(observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Actions
        liveData.value = 0
        liveData.value = nil
        liveData.value = 2
        liveData.value = 3
        liveData.value = 4

        // Assertions

        guard 5 == mockObserver.valuesObserved.count else {
            XCTFail("Expected to be notified 5 times of value changes: \(mockObserver.valuesObserved.count)")
            return
        }

        XCTAssertEqual(0, mockObserver.valuesObserved[0])
        XCTAssertNil(mockObserver.valuesObserved[1])
        XCTAssertEqual(2, mockObserver.valuesObserved[2])
        XCTAssertEqual(3, mockObserver.valuesObserved[3])
        XCTAssertEqual(4, mockObserver.valuesObserved[4])
    }
    
    func testObserverNotNotifiedOfAnyChangeWhenLifecycleInitialized() {
        // Setup
        let liveData = MutableLiveData<Int?>(initialValue: 0)
        let mockOwner = MockLifecycleOwner(initialState: .initialized)
        let mockObserver = MockLiveDataObserver<Int?>()
        let handle = liveData.observe(owner: mockOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Actions
        liveData.value = 1
        liveData.value = 1
        liveData.value = nil
        liveData.value = 2
        liveData.value = 3
        liveData.value = 5

        // Assertions
        XCTAssertEqual(0, mockObserver.valuesObserved.count)
    }

    func testObserverNotNotifiedOfAnyChangeWhenLifecycleCreated() {
        // Setup
        let liveData = MutableLiveData<Int?>(initialValue: 0)
        let mockOwner = MockLifecycleOwner(initialState: .created)
        let mockObserver = MockLiveDataObserver<Int?>()
        let handle = liveData.observe(owner: mockOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Actions
        liveData.value = 1
        liveData.value = 1
        liveData.value = nil
        liveData.value = 2
        liveData.value = 3
        liveData.value = 5

        // Assertions
        XCTAssertEqual(0, mockObserver.valuesObserved.count)
    }

    func testObserverNotifiedOnEveryChangeWhenLifecycleStarted() {
        // Setup
        let liveData = MutableLiveData<Int?>(initialValue: 0)
        let mockOwner = MockLifecycleOwner(initialState: .started)
        let mockObserver = MockLiveDataObserver<Int?>()
        let handle = liveData.observe(owner: mockOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Actions
        liveData.value = 1
        liveData.value = nil
        liveData.value = 2
        liveData.value = 3
        liveData.value = 5

        // Assertions

        guard 5 == mockObserver.valuesObserved.count else {
            XCTFail("Expected to be notified 5 times of value changes: \(mockObserver.valuesObserved.count)")
            return
        }

        XCTAssertEqual(1, mockObserver.valuesObserved[0])
        XCTAssertNil(mockObserver.valuesObserved[1])
        XCTAssertEqual(2, mockObserver.valuesObserved[2])
        XCTAssertEqual(3, mockObserver.valuesObserved[3])
        XCTAssertEqual(5, mockObserver.valuesObserved[4])
    }

    func testObserverNotifiedOnEveryChangeWhenLifecycleResumed() {
        // Setup
        let liveData = MutableLiveData<Int?>(initialValue: 0)
        let mockOwner = MockLifecycleOwner(initialState: .resumed)
        let mockObserver = MockLiveDataObserver<Int?>()
        let handle = liveData.observe(owner: mockOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Actions
        liveData.value = 1
        liveData.value = nil
        liveData.value = 2
        liveData.value = 3
        liveData.value = 5

        // Assertions

        guard 5 == mockObserver.valuesObserved.count else {
            XCTFail("Expected to be notified 5 times of value changes: \(mockObserver.valuesObserved.count)")
            return
        }

        XCTAssertEqual(1, mockObserver.valuesObserved[0])
        XCTAssertNil(mockObserver.valuesObserved[1])
        XCTAssertEqual(2, mockObserver.valuesObserved[2])
        XCTAssertEqual(3, mockObserver.valuesObserved[3])
        XCTAssertEqual(5, mockObserver.valuesObserved[4])
    }

    func testObserverNotNotifiedOfAnyChangeWhenLifecycleDestroyed() {
        // Setup
        let liveData = MutableLiveData<Int?>(initialValue: 0)
        let mockOwner = MockLifecycleOwner(initialState: .destroyed)
        let mockObserver = MockLiveDataObserver<Int?>()
        let handle = liveData.observe(owner: mockOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Actions
        liveData.value = 1
        liveData.value = nil
        liveData.value = 2
        liveData.value = 3
        liveData.value = 5

        // Assertions
        XCTAssertEqual(0, mockObserver.valuesObserved.count)
    }

    func testObserverNotifiedOfChangeWhenLifecycleInactiveWhenLifecycleTransitionsToStarted() {
        // Setup

        let liveData = MutableLiveData<Int>(initialValue: 0)
        let mockOwner = MockLifecycleOwner(initialState: .created)
        let mockObserver = MockLiveDataObserver<Int>()
        let handle = liveData.observe(owner: mockOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Actions
        liveData.value = 123
        mockOwner.transitionToState(.started)

        // Assertions

        guard 1 == mockObserver.valuesObserved.count else {
            XCTFail("Expected to be notified 1 time of value changes: \(mockObserver.valuesObserved.count)")
            return
        }

        XCTAssertEqual(123, mockObserver.valuesObserved[0])
    }

    func test_GivenLifecycleInactive_WhenWhenLifecycleTransitionsToStarted_ThenObserverOnlyNotifiedOfLatestChange() {
        // Setup

        let liveData = MutableLiveData<Int>(initialValue: 0)
        let mockOwner = MockLifecycleOwner(initialState: .created)
        let mockObserver = MockLiveDataObserver<Int>()
        let handle = liveData.observe(owner: mockOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Actions
        liveData.value = 1
        liveData.value = 2
        liveData.value = 3
        liveData.value = 4
        liveData.value = 5
        mockOwner.transitionToState(.started)

        // Assertions

        guard 1 == mockObserver.valuesObserved.count else {
            XCTFail("Expected to be notified 1 time of value changes: \(mockObserver.valuesObserved.count)")
            return
        }

        XCTAssertEqual(5, mockObserver.valuesObserved[0])
    }

    func testObserverNotifiedOfPendingChangesOnlyWhenItsLifecycleOwnerBecomesActive() {
        // Setup

        let liveData = MutableLiveData<Int>(initialValue: 0)

        let mockOwnerA = MockLifecycleOwner(initialState: .created)
        let mockObserverA = MockLiveDataObserver<Int>()
        let handleA = liveData.observe(owner: mockOwnerA, observer: mockObserverA.observer)
        defer {
            liveData.removeObserver(handle: handleA)

        }

        let mockOwnerB = MockLifecycleOwner(initialState: .created)
        let mockObserverB = MockLiveDataObserver<Int>()
        let handleB = liveData.observe(owner: mockOwnerB, observer: mockObserverB.observer)
        defer {
            liveData.removeObserver(handle: handleB)
            
        }

        // Actions
        
        liveData.value = 123
        mockOwnerA.transitionToState(.started)

        // Assertions

        XCTAssertEqual(1, mockObserverA.valuesObserved.count)
        XCTAssertEqual(0, mockObserverB.valuesObserved.count)
    }

    func test_GivenLifecycleStarted_WhenValueChangedAndLifecycleStopsAndLifecycleStarts_ThenValueShouldNotBeSentAgain() {
        // Given lifecycle owner in an active state
        let mockOwner = MockLifecycleOwner(initialState: .started)

        // And an live data observer for that lifecycle owner
        let liveData = MutableLiveData<Int>(initialValue: 0)
        let mockObserver = MockLiveDataObserver<Int>()
        let handle = liveData.observe(owner: mockOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // When the live data value is changed
        liveData.value = 1

        // And the lifecycle owner becomes inactive
        mockOwner.transitionToState(.created)

        // And the lifecycle owner becomes active again
        mockOwner.transitionToState(.started)

        // Then the live data observer should have received one notification
        guard 1 == mockObserver.valuesObserved.count else {
            XCTFail("Expected to be notified 1 time of value changes: \(mockObserver.valuesObserved.count)")
            return
        }

        // And the live data observer should have been notified of the correct value
        XCTAssertEqual([1], mockObserver.valuesObserved)
    }

    // MARK: Test notifications not sent for equal value

    func test_WhenEqualValuesSetConsecutively_ThenObserverNotifiedOnce() {
        // Given lifecycle owner in an active state
        let mockOwner = MockLifecycleOwner(initialState: .started)

        // And an live data observer for that lifecycle owner
        let liveData = MutableLiveData<Int>(initialValue: 0)
        let mockObserver = MockLiveDataObserver<Int>()
        let handle = liveData.observe(owner: mockOwner, observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // When the live data value is set to equal values on consecutive calls
        liveData.value = 1
        liveData.value = 1
        liveData.value = 1

        // Then the live data observer should only be notified once
        guard 1 == mockObserver.valuesObserved.count else {
            XCTFail("Expected to be notified 1 time of value changes: \(mockObserver.valuesObserved.count)")
            return
        }

        // And the live data observer should have been notified of the correct value
        XCTAssertEqual([1], mockObserver.valuesObserved)
    }
    
}
