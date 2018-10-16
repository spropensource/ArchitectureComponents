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

#if os(iOS)

import UIKit


open class LifecycleTableViewController: UITableViewController, LifecycleOwner {
    // TODO: write tests for this class

    // MARK: Properties

    private var lifecycleAppState: UIApplication.State = .inactive
    private var lifecycleViewDisplayed: Bool = false

    // This property is defined as lazy to work-around Swift initialization
    // requirements. You cannot use `self` before calling `super`, so
    // `lifecycleRegistry` cannot be initialized before `super`. However, since
    // `lifecycleRegistry` is not optional, it must be assigned before calling
    // super. The trick is to define the `lifecycleRegistry` property as lazy,
    // allowing us to avoid making it optional AND letting us use `self` in its
    // initializer.
    private lazy var lifecycleRegistry: LifecycleRegistry = LifecycleRegistry(provider: self)

    // MARK: init / deinit

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.sharedInitialization()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInitialization()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)

        self.onDestroy()
        self.lifecycleRegistry.markState(.destroyed)
    }

    // MARK: UIViewController

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.lifecycleViewDisplayed = true
        self.updateLifecycleState()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        self.lifecycleViewDisplayed = false
        self.updateLifecycleState()
    }

    // MARK: LifecycleOwner

    public var lifecycle: Lifecycle { return self.lifecycleRegistry }

    // MARK: LifecycleViewController

    open func onCreate() { }

    open func onStart() { }

    open func onResume() { }

    open func onPause() { }

    open func onStop() { }

    open func onDestroy() { }

    // MARK: Private (Initialization)

    private func sharedInitialization() {
        self.lifecycleAppState = UIApplication.shared.applicationState
        self.lifecycleViewDisplayed = false

        self.registerForNotifications()

        self.updateLifecycleState()
    }

    // MARK: Private (Notifications)

    @objc private func handleApplicationStateChangeNotification(_ note: Notification) {
        self.lifecycleAppState = UIApplication.shared.applicationState
        self.updateLifecycleState()
    }

    private func registerForNotifications() {
        let center = NotificationCenter.default
        let app = UIApplication.shared

        center.addObserver(
            self,
            selector: #selector(LifecycleTableViewController.handleApplicationStateChangeNotification(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: app
        )
        center.addObserver(
            self,
            selector: #selector(LifecycleTableViewController.handleApplicationStateChangeNotification(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: app
        )
        center.addObserver(
            self,
            selector: #selector(LifecycleTableViewController.handleApplicationStateChangeNotification(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: app
        )
        center.addObserver(
            self,
            selector: #selector(LifecycleTableViewController.handleApplicationStateChangeNotification(_:)),
            name: UIApplication.willResignActiveNotification,
            object: app
        )
    }

    // MARK: Private (Lifecycle State Change)

    internal static func lifecycleStateForVCState(appState: UIApplication.State, viewDisplayed: Bool) -> LifecycleState {
        // DEVELOPER NOTE: This method has `internal` access to allow for
        // automated testing.

        let lcState: LifecycleState

        if viewDisplayed {
            switch appState {
            case .active:     lcState = .resumed
            case .inactive:   lcState = .started
            case .background: lcState = .created
            }
        } else {
            lcState = .created
        }

        return lcState
    }

    private func updateLifecycleState() {
        // determine the state we should be in
        let targetState = LifecycleViewController.lifecycleStateForVCState(
            appState: self.lifecycleAppState,
            viewDisplayed: self.lifecycleViewDisplayed
        )

        // transition to the target state, ensuring our onCreate(), onStart(),
        // etc. are called before the observers are notified of the state
        // changes
        self.lifecycleRegistry.markState(targetState) { (event) in
            switch event {
            case .create:  self.onCreate()
            case .start:   self.onStart()
            case .resume:  self.onResume()
            case .pause:   self.onPause()
            case .stop:    self.onStop()
            case .destroy: self.onDestroy()
            }
        }
    }

}

#endif
