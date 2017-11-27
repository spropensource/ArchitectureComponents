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

class LifecycleStateTests: XCTestCase {
    
    // MARK: - eventsToState

    // MARK: (Single-Step)
    
    func testEventsToState_initializeToCreated_returnsCreate() {
        let initialized = LifecycleState.initialized
        do {
            let events = try initialized.eventsToState(.created)
            XCTAssertEqual([.create], events)
        } catch { XCTFail() }
    }
    
    func testEventsToState_createdToStarted_returnsStart() {
        let created = LifecycleState.created
        do {
            let events = try created.eventsToState(.started)
            XCTAssertEqual([.start], events)
        } catch { XCTFail() }
    }

    func testEventsToState_startedToResumed_returnsResume() {
        let started = LifecycleState.started
        do {
            let events = try started.eventsToState(.resumed)
            XCTAssertEqual([.resume], events)
        } catch { XCTFail() }
    }

    func testEventsToState_resumedToStarted_returnsPause() {
        let resumed = LifecycleState.resumed
        do {
            let events = try resumed.eventsToState(.started)
            XCTAssertEqual([.pause], events)
        } catch { XCTFail() }
    }

    func testEventsToState_startedToCreated_returnsStop() {
        let started = LifecycleState.started
        do {
            let events = try started.eventsToState(.created)
            XCTAssertEqual([.stop], events)
        } catch { XCTFail() }
    }

    func testEventsToState_createdToDestroyed_returnsDestroy() {
        let created = LifecycleState.created
        do {
            let events = try created.eventsToState(.destroyed)
            XCTAssertEqual([.destroy], events)
        } catch { XCTFail() }
    }

    // MARK: (Multi-Step)

    func testEventsToState_initializedToStarted_returnsCreateAndStart() {
        let initialized = LifecycleState.initialized
        do {
            let events = try initialized.eventsToState(.started)
            XCTAssertEqual([.create, .start], events)
        } catch { XCTFail() }
    }

    func testEventsToState_initializedToResumed_returnsCreateAndStartAndResume() {
        let initialized = LifecycleState.initialized
        do {
            let events = try initialized.eventsToState(.resumed)
            XCTAssertEqual([.create, .start, .resume], events)
        } catch { XCTFail() }
    }

    func testEventsToState_initializedToDestroyed_returnsCreateAndDestroy() {
        let initialized = LifecycleState.initialized
        do {
            let events = try initialized.eventsToState(.destroyed)
            XCTAssertEqual([.create, .destroy], events)
        } catch { XCTFail() }
    }

    func testEventsToState_createdToResumed_returnsStartAndResume() {
        let created = LifecycleState.created
        do {
            let events = try created.eventsToState(.resumed)
            XCTAssertEqual([.start, .resume], events)
        } catch { XCTFail() }
    }

    func testEventsToState_startedToDestroyed_returnsStopAndDestroy() {
        let started = LifecycleState.started
        do {
            let events = try started.eventsToState(.destroyed)
            XCTAssertEqual([.stop, .destroy], events)
        } catch { XCTFail() }
    }

    func testEventsToState_resumedToCreated_returnsPauseAndStop() {
        let resumed = LifecycleState.resumed
        do {
            let events = try resumed.eventsToState(.created)
            XCTAssertEqual([.pause, .stop], events)
        } catch { XCTFail() }
    }

    func testEventsToState_resumedToDestroyed_returnsPauseAndStopAndDestroy() {
        let resumed = LifecycleState.resumed
        do {
            let events = try resumed.eventsToState(.destroyed)
            XCTAssertEqual([.pause, .stop, .destroy], events)
        } catch { XCTFail() }
    }

    // MARK: (Same State)

    func testEventsToState_fromAndToAreSame_returnsEmptyArray() {
        let allStates: [LifecycleState] = [.initialized, .destroyed, .created, .started, .resumed]
        for state in allStates {
            do {
                let events = try state.eventsToState(state)
                XCTAssertEqual(0, events.count)
            } catch { XCTFail() }
        }
    }

    // MARK: (Invalid)
    
    func testEventsToState_destroyedToCreated_throws() {
        let destroyed = LifecycleState.destroyed
        do {
            _ = try destroyed.eventsToState(.created)
            XCTFail()
        } catch (let error) {
            if case LifecycleError.invalidStateTransition(from: let f, to: let t) = error {
                XCTAssertEqual(.destroyed, f)
                XCTAssertEqual(.created, t)
            } else {
                XCTFail()
            }
        }
    }

    func testEventsToState_createdToInitialized_throws() {
        let created = LifecycleState.created
        do {
            _ = try created.eventsToState(.initialized)
            XCTFail()
        } catch (let error) {
            if case LifecycleError.invalidStateTransition(from: let f, to: let t) = error {
                XCTAssertEqual(.created, f)
                XCTAssertEqual(.initialized, t)
            } else {
                XCTFail()
            }
        }
    }

}
