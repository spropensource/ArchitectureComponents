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


class MutableLiveData_ObserverManagementTests: XCTestCase {

    func testFromMainQueuePostedValuesFollowSetValues() {
        // Setup

        let liveData = MutableLiveData(initialValue: 0)

        let mockObserver = MockLiveDataObserver<Int>()
        let handle = liveData.observeForever(observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Actions

        liveData.postValue(1)
        liveData.value = 2

        allowQueuedBlocksForMainToProcess()

        // Assertions

        XCTAssertEqual([2, 1], mockObserver.valuesObserved)
    }

    func testMultipleUndispatchedCallsToPostOnlyResultInOneValueChange() {
        // Setup

        let liveData = MutableLiveData(initialValue: 0)

        let mockObserver = MockLiveDataObserver<Int>()
        let handle = liveData.observeForever(observer: mockObserver.observer)
        defer { liveData.removeObserver(handle: handle) }

        // Actions

        liveData.postValue(1)
        liveData.postValue(2)
        liveData.postValue(3)
        liveData.postValue(4)
        liveData.postValue(5)

        allowQueuedBlocksForMainToProcess()

        // Assertions

        XCTAssertEqual([5], mockObserver.valuesObserved)
    }

    // MARK: Private (Helpers)

    func allowQueuedBlocksForMainToProcess() {
        let expectation = self.expectation(description: "Allow queued blocks for main queue to be processed")
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                expectation.fulfill()
            }
        }
        self.waitForExpectations(timeout: 0.1)
    }

}
