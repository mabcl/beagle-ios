/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import XCTest
import SnapshotTesting
@testable import Beagle

final class BeagleNavigatorTests: XCTestCase {

    func testOpenValidExternalURL() {

        // Given
        let opener = URLOpenerDumb()
        let action = Navigate.openExternalURL("https://localhost:8080")
        let dependencies = BeagleScreenDependencies(opener: opener)
        let controller = BeagleControllerStub(dependencies: dependencies)
        let sut = BeagleNavigator()

        // When
        sut.navigate(action: action, controller: controller, origin: nil)

        // Then
        XCTAssert(opener.hasInvokedTryToOpen == true)
    }
    
    func testOpenNativeRouteShouldNotPushANativeScreenToNavigationWhenDeepLinkHandlerItsNotSet() {
        // Given
        let sut = BeagleNavigator()
        let action = Navigate.openNativeRoute(.init(route: "https://example.com/screen.json"))
        let controller = BeagleControllerStub()
        let navigation = BeagleNavigationController(rootViewController: controller)
        
        // When
        sut.navigate(action: action, controller: controller, origin: nil)
        
        //Then
        XCTAssert(navigation.viewControllers.count == 1)
    }

    func testResetApplicationShouldReplaceApplicationStackWithRemoteScreen() {

        // Given
        let windowMock = WindowMock()
        let windowManager = WindowManagerDumb(window: windowMock)
        let viewClient = ViewClientStub(componentResult: .success(ComponentDummy()))
        let dependencies = BeagleScreenDependencies(viewClient: viewClient, windowManager: windowManager)
        
        let sut = BeagleNavigator()
        let controller = BeagleControllerStub(dependencies: dependencies)

        let resetRemote = Navigate.resetApplication(.remote(.init(url: "https://example.com/screen.json")))

        // When
        sut.navigate(action: resetRemote, controller: controller, origin: nil)

        // Then
        XCTAssert(windowMock.hasInvokedReplaceRootViewController == true)
    }

    func testResetApplicationShouldReplaceApplicationStackWithDeclarativeScreen() {

        // Given
        let windowMock = WindowMock()
        let windowManager = WindowManagerDumb(window: windowMock)
        let dependencies = BeagleScreenDependencies(windowManager: windowManager)
        let sut = BeagleNavigator()
        let controller = BeagleControllerStub(dependencies: dependencies)

        let resetDeclarative = Navigate.resetApplication(.declarative(Screen(child: Text(text: "Declarative"))))

        // When
        sut.navigate(action: resetDeclarative, controller: controller, origin: nil)

        // Then
        XCTAssert(windowMock.hasInvokedReplaceRootViewController == true)
    }

    func testResetStackShouldReplaceNavigationStack() {
        let resetRemote = Navigate.resetStack(.remote(.init(url: "https://example.com/screen.json")))
        let resetDeclarative = Navigate.resetStack(.declarative(Screen(child: Text(text: "Declarative"))))
        
        resetStackTest(resetRemote)
        resetStackTest(resetDeclarative)
    }
    
    private func resetStackTest(_ navigate: Navigate) {
        let sut = BeagleNavigator()
        let firstViewController = UIViewController()
        
        let viewClient = ViewClientStub(componentResult: .success(ComponentDummy()))
        let dependencies = BeagleScreenDependencies(viewClient: viewClient)
        let secondViewController = BeagleControllerStub(dependencies: dependencies)
        let navigation = BeagleNavigationController()
        navigation.viewControllers = [firstViewController, secondViewController]
        
        sut.navigate(action: navigate, controller: secondViewController, origin: nil)
        
        XCTAssertEqual(1, navigation.viewControllers.count)
        XCTAssert(navigation.viewControllers.last is BeagleController)
    }

    func testPushViewShouldPushScreenInNavigation() {
        let addViewRemote = Navigate.pushView(.remote(.init(url: "https://example.com/screen.json")))
        let addViewDeclarative = Navigate.pushView(.declarative(Screen(child: Text(text: "Declarative"))))
        
        addViewTest(addViewRemote)
        addViewTest(addViewDeclarative)
    }
    
    private func addViewTest(_ navigate: Navigate) {
        let sut = BeagleNavigator()
        let viewClient = ViewClientStub(componentResult: .success(ComponentDummy()))
        let dependencies = BeagleScreenDependencies(viewClient: viewClient)
        let firstViewController = BeagleControllerStub(dependencies: dependencies)
        let navigation = BeagleNavigationController(rootViewController: firstViewController)
        
        sut.navigate(action: navigate, controller: firstViewController, origin: nil)
        
        XCTAssertEqual(2, navigation.viewControllers.count)
        XCTAssert(navigation.viewControllers.last is BeagleController)
    }

    func testPopStackShouldDismissNavigation() {
        // Given
        let sut = BeagleNavigator()
        let action = Navigate.popStack()
        let navigationSpy = BeagleControllerNavigationSpy()

        // When
        sut.navigate(action: action, controller: navigationSpy, origin: nil)

        // Then
        XCTAssert(navigationSpy.dismissViewControllerCalled)
    }

    func testPopViewShouldPopNavigationScreen() {
        // Given
        let sut = BeagleNavigator()
        let action = Navigate.popView()
        let firstViewController = BeagleControllerStub()
        let secondViewController = UIViewController()
        let thirdViewController = BeagleControllerStub()
        let navigation = BeagleNavigationController()
        navigation.viewControllers = [firstViewController, secondViewController, thirdViewController]

        // When
        sut.navigate(action: action, controller: thirdViewController, origin: nil)

        // Then
        XCTAssert(navigation.viewControllers.count == 2)
    }
    
    func testPopViewWithOneViewInStackShouldPopTheStack() {
        // Given
        let sut = BeagleNavigator()
        let action = Navigate.popView()
        let navigationSpy = BeagleControllerNavigationSpy()
        let navigation = BeagleNavigationController()
        navigation.viewControllers = [navigationSpy]

        // When
        sut.navigate(action: action, controller: navigationSpy, origin: nil)

        // Then
        XCTAssert(navigationSpy.dismissViewControllerCalled)
    }

    func testPopToViewShouldNotNavigateWhenScreenIsNotFound() {
        
        // Given
        let sut = BeagleNavigator()
        let action = Navigate.popToView("screenURL1")
        let dependencies = BeagleScreenDependencies(urlBuilder: UrlBuilder())
        let vc1 = BeagleControllerStub(dependencies: dependencies)
        let vc2 = BeagleControllerStub(dependencies: dependencies)
        let vc3 = BeagleControllerStub(dependencies: dependencies)
        let vc4 = UIViewController()
        let navigation = BeagleNavigationController()
        navigation.viewControllers = [vc1, vc2, vc3, vc4]

        // When
        sut.navigate(action: action, controller: vc2, origin: nil)

        // Then
        XCTAssertEqual(navigation.viewControllers.count, 4)
        XCTAssertEqual(navigation.viewControllers.last, vc4)
    }

    func testPopToViewShouldRemoveFromStackScreensAfterTargetScreen() {
        // Given
        let screenURL1 = "https://example.com/screen1.json"
        let screenURL2 = "https://example.com/screen2.json"
        let screenURL3 = "https://example.com/screen3.json"
        let sut = BeagleNavigator()
        let action = Navigate.popToView("https://example.com/@{'screen2.json'}")
        let dependencies = BeagleScreenDependencies(urlBuilder: UrlBuilder())
        let vc1 = BeagleControllerStub(.remote(.init(url: screenURL1)), dependencies: dependencies)
        let vc2 = BeagleControllerStub(.remote(.init(url: screenURL2)), dependencies: dependencies)
        let vc3 = BeagleControllerStub(.remote(.init(url: screenURL3)), dependencies: dependencies)
        let vc4 = UIViewController()
        let navigation = BeagleNavigationController()
        navigation.viewControllers = [vc1, vc2, vc3, vc4]

        // When
        sut.navigate(action: action, controller: vc3, origin: UIView())

        // Then
        XCTAssertEqual(navigation.viewControllers.count, 2)
        XCTAssertEqual(navigation.viewControllers.last, vc2)
    }
    
    func testPopToViewAbsoluteURL() {
        let dependencies = BeagleDependencies()
        dependencies.urlBuilder.baseUrl = URL(string: "https://server.com/path/")
        let sut = BeagleNavigator()
        
        let target = BeagleControllerStub(.remote(.init(url: "/screen")), dependencies: dependencies)
        let declarative = BeagleControllerStub(.declarative(Screen(child: ComponentDummy())), dependencies: dependencies)
        let remote = BeagleControllerStub(.remote(.init(url: "remote")), dependencies: dependencies)
        let current = BeagleControllerStub(.declarativeText("{}"), dependencies: dependencies)

        let navigation = UINavigationController()
        let stack = [target, declarative, remote, current]
        navigation.viewControllers = stack
        
        sut.navigate(
            action: Navigate.popToView("https://server.com/path/screen"),
            controller: current,
            origin: nil
        )
        XCTAssertEqual(navigation.viewControllers.last, target)
        
        navigation.viewControllers = stack
        sut.navigate(
            action: Navigate.popToView("/screen"),
            controller: current,
            origin: nil
        )
        XCTAssertEqual(navigation.viewControllers.last, target)
    }
    
    func testPopToViewByIdentifier() {
        // Given
        let sut = BeagleNavigator()
        let vc1 = BeagleControllerStub(.declarative(Screen(id: "1", child: Text(text: "Screen 1"))))
        let vc2 = BeagleControllerStub(.declarative(Screen(id: "2", child: Text(text: "Screen 2"))))
        let vc3 = UIViewController()
        let vc4 = BeagleControllerStub(.declarative(Screen(id: "4", child: Text(text: "Screen 4"))))
        let action = Navigate.popToView("2")
        
        let navigation = UINavigationController()
        navigation.viewControllers = [vc1, vc2, vc3, vc4]
        
        // When
        sut.navigate(action: action, controller: vc4, origin: nil)
        
        // Then
        XCTAssert(navigation.viewControllers.count == 2)
        XCTAssert(navigation.viewControllers.last == vc2)
    }

    func testPushStackShouldPresentTheScreen() {
        let presentViewRemote = Navigate.pushStack(.remote(.init(url: "https://example.com/screen.json")))
        let presentViewDeclarative = Navigate.pushStack(.declarative(Screen(child: Text(text: "Declarative"))))
        
        pushStackTest(presentViewRemote)
        pushStackTest(presentViewDeclarative)
    }
    
    private func pushStackTest(_ navigate: Navigate) {
        let sut = BeagleNavigator()
        let viewClient = ViewClientStub(componentResult: .success(ComponentDummy()))
        let dependencies = BeagleScreenDependencies(viewClient: viewClient)
        let navigationSpy = BeagleControllerNavigationSpy(dependencies: dependencies)
        
        sut.navigate(action: navigate, controller: navigationSpy, origin: nil)
        
        XCTAssertNotNil(navigationSpy.viewControllerToPresent)
    }
    
    func testOpenNativeRouteShouldPushANativeScreenWithData() {
        // Given
        let deepLinkSpy = DeepLinkHandlerSpy()
        let sut = BeagleNavigator()
        
        let data = ["uma": "uma", "dois": "duas"]
        let path = "https://example.com/screen.json"
        let action = Navigate.openNativeRoute(.init(route: path, data: data))
        let firstViewController = BeagleControllerStub()
        firstViewController.dependencies = BeagleScreenDependencies(deepLinkHandler: deepLinkSpy)
        let navigation = BeagleNavigationController(rootViewController: firstViewController)
        
        // When
        sut.navigate(action: action, controller: firstViewController, origin: nil)
        
        //Then
        XCTAssertEqual(2, navigation.viewControllers.count)
        XCTAssertEqual(data, deepLinkSpy.calledData)
        XCTAssertEqual(path, deepLinkSpy.calledPath)
    }
    
    func testRegisterNavigationController() {
        // Given
        let controllerId = "customId"
        
        // When
        dependencies.navigation.registerNavigationController(builder: BeagleNavigationStub.init, forId: controllerId)
        
        // Then
        XCTAssertTrue(dependencies.navigation.navigationController(forId: controllerId) is BeagleNavigationStub)
    }

    func testDefaultNavigationWithCustom() {
        // Given
        let defaultNavigation = BeagleNavigationStub()
        dependencies.navigation.registerDefaultNavigationController(builder: { defaultNavigation })

        // When
        let result = dependencies.navigation.navigationController(forId: nil)

        // Then
        XCTAssertTrue(result === defaultNavigation)
    }
    
    func testIfNavigationIsPushedWithSetContext() {
        // Given
        let sut = BeagleNavigator()
        let dependencies = BeagleScreenDependencies(viewClient: ViewClientStub(componentResult: .success(ComponentDummy())))

        let url: DynamicObject = .string("https://example.com/screen.json")
        let pushViewRemote = Navigate.pushView(.remote(.init(url: "@{url}", shouldPrefetch: false)))
        let button = Button(text: "@{url}", onPress: [pushViewRemote])
        let setContext = SetContext(contextId: "url", path: nil, value: url)
        
        let controller = BeagleScreenViewController(viewModel: .init(screenType: .declarative(button.toScreen()), dependencies: dependencies))
        let view = button.toView(renderer: controller.renderer)
        let navigation = BeagleNavigationController(rootViewController: controller)

        // When
        view.setContext(Context(id: "url", value: "initial"))
        controller.bindings.config()
        setContext.execute(controller: controller, origin: view)
        sut.navigate(action: pushViewRemote, controller: controller, animated: false, origin: view)
        
        // Then
        XCTAssertEqual(2, navigation.viewControllers.count)
        XCTAssertEqual(pushViewRemote.newPath?.url.evaluate(with: view), url.description)
    }
    
    func testResetApplicationShouldSetContextOnDestination() {
        let windowMock = WindowMock()
        let windowManager = WindowManagerDumb(window: windowMock)
        let viewClient = ViewClientStub(componentResult: .success(ComponentDummy()))
        let dependencies = BeagleScreenDependencies(viewClient: viewClient, windowManager: windowManager)
        
        let sut = BeagleNavigator()
        let controller = BeagleControllerStub(dependencies: dependencies)
        let origin = UIView()
        origin.setContext(Context(id: "contextId", value: "value"))
        let navContext = NavigationContext(path: Path(rawValue: "path"), value: ["param": "@{contextId}"])
        
        let action = Navigate.resetApplication(.remote(.init(url: "remote")), navigationContext: navContext)
        
        // When
        sut.navigate(action: action, controller: controller, animated: false, origin: origin)
        
        // Then
        _assertInlineSnapshot(
            matching: windowMock.controller?.view.getContext(with: NavigationContext.id)?.value,
            as: .dump,
            with: """
        ▿ Optional<Context>
          ▿ some: Context
            - id: "navigationContext"
            - value: [path: [param: value]]
        """)
    
    }
        
    func testResetStackShouldSetContextOnDestination() {
        let navigation = BeagleNavigationController()
        let navContext = NavigationContext(value: ["resetStack": "value"])
        let action = Navigate.resetStack(.remote(.init(url: "remote")), navigationContext: navContext)
        
        testSetContextOnDestination(navigation, action, snapshot: """
        ▿ Optional<Context>
          ▿ some: Context
            - id: "navigationContext"
            - value: [resetStack: value]
        """
        )
    }
        
    func testPushViewShouldSetContextOnDestination() {
        let navigation = BeagleNavigationController()
        let navContext = NavigationContext(value: ["pushView": "value"])
        let action = Navigate.pushView(.remote(.init(url: "remote")), navigationContext: navContext)
        
        testSetContextOnDestination(navigation, action, snapshot: """
        ▿ Optional<Context>
          ▿ some: Context
            - id: "navigationContext"
            - value: [pushView: value]
        """
        )
    }
        
    func testPopViewShouldSetContextOnDestination() {
        let rootController = BeagleControllerStub(.declarative(Screen(child: Text(text: "root"))))
        let navigation = BeagleNavigationController(rootViewController: rootController)
        let navContext = NavigationContext(value: ["popView": "value"])
        let action = Navigate.popView(navigationContext: navContext)
        
        testSetContextOnDestination(navigation, action, snapshot: """
        ▿ Optional<Context>
          ▿ some: Context
            - id: "navigationContext"
            - value: [popView: value]
        """
        )
    }
        
    func testPopToViewShouldSetContextOnDestination() {
        let rootController = BeagleControllerStub(.declarative(Screen(id: "root", child: Text(text: "root"))))
        let navigation = BeagleNavigationController(rootViewController: rootController)
        let navContext = NavigationContext(value: ["popToView": "value"])
        let action = Navigate.popToView("root", navigationContext: navContext)
        
        testSetContextOnDestination(navigation, action, snapshot: """
        ▿ Optional<Context>
          ▿ some: Context
            - id: "navigationContext"
            - value: [popToView: value]
        """
        )
    }
    
    var setContextDependencies: BeagleScreenDependencies {
        let viewClient = ViewClientStub(componentResult: .success(ComponentDummy()))
        return BeagleScreenDependencies(viewClient: viewClient)
    }
    
    private func testSetContextOnDestination(_ navigation: BeagleNavigationController, _ action: Navigate, snapshot: String) {
        // Given
        let sut = BeagleNavigator()
        let controller = BeagleControllerStub(dependencies: setContextDependencies)
        navigation.viewControllers = navigation.viewControllers + [controller]
        let origin = UIView()
        origin.setContext(Context(id: "contextId", value: "value"))
        
        // When
        sut.navigate(action: action, controller: controller, animated: false, origin: origin)
        
        // Then
        _assertInlineSnapshot(
            matching: navigation.topViewController?.view.getContext(with: NavigationContext.id)?.value,
            as: .dump,
            with: snapshot
        )
    }
        
    func testPushStackShouldSetContextOnDestination() {
        // Given
        let sut = BeagleNavigator()
        let controllerSpy = BeagleControllerNavigationSpy(dependencies: setContextDependencies)
        let navContext = NavigationContext(value: ["pushStack": "value"])
        let action = Navigate.pushStack(.remote(.init(url: "remote")), navigationContext: navContext)
        
        // When
        sut.navigate(action: action, controller: controllerSpy, animated: false, origin: nil)
        
        // Then
        let destination = (controllerSpy.viewControllerToPresent as? BeagleNavigationController)?.topViewController
        _assertInlineSnapshot(
            matching: destination?.view.getContext(with: NavigationContext.id)?.value,
            as: .dump,
            with: """
        ▿ Optional<Context>
          ▿ some: Context
            - id: "navigationContext"
            - value: [pushStack: value]
        """
        )
    }
        
    func testPopStackShouldSetContextOnDestination() {
        // Given
        let sut = BeagleNavigator()
        let manager = ApplicationManagerMock()
        sut.applicationManager = manager
        let controllerSpy = BeagleControllerStub(dependencies: setContextDependencies)
        let navContext = NavigationContext(value: ["popStack": "value"])
        let action = Navigate.popStack(navigationContext: navContext)
        
        // When
        sut.navigate(action: action, controller: controllerSpy, animated: false, origin: nil)
        
        // Then
        _assertInlineSnapshot(
            matching: manager.root.view.getContext(with: NavigationContext.id)?.value,
            as: .dump,
            with: """
        ▿ Optional<Context>
          ▿ some: Context
            - id: "navigationContext"
            - value: [popStack: value]
        """
        )
    }
    
}

struct ApplicationManagerMock: ApplicationManager {
    let root = UIViewController()
    
    func topViewController(base: UIViewController?) -> UIViewController? {
        root.view.setContext(Context(id: NavigationContext.id, value: nil))
        return root
    }
}

class DeepLinkHandlerSpy: DeepLinkScreenManaging {
    var calledPath: String?
    var calledData: [String: String]?
    
    func getNativeScreen(with path: String, data: [String: String]?) throws -> UIViewController {
        calledData = data
        calledPath = path
        return UIViewController()
    }
}

class BeagleControllerNavigationSpy: BeagleControllerStub {
    private(set) var viewControllerToPresent: UIViewController?
    private(set) var dismissViewControllerCalled = false
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        self.viewControllerToPresent = viewControllerToPresent
        super.present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissViewControllerCalled = true
        super.dismiss(animated: flag, completion: completion)
    }
}
