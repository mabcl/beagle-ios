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

final class ScreenComponentTests: XCTestCase {
    
    func testScreenDecoding() throws {
        let screen: Screen = try componentFromJsonFile(fileName: "screen")
        assertSnapshot(matching: screen, as: .dump)
    }

    func test_initWithBuilders_shouldReturnExpectedInstance() {
        // Given / When
        let component = Screen(
            child: Text(text: "text")
        )

        // Then
        XCTAssert(component.child is Text)
    }
    
    func test_contentShouldUseOnlyTheSpaceRequiredByFlexRules() {
        let component = Screen(
            safeArea: SafeArea.all,
            navigationBar: .init(title: "Test Flex"),
            child: Container(
                children: [
                    Container(
                        children: [Text(text: "Line 0,\nLine 1,\nLine 2,\nLine 3,\nLine 4.")],
                        style: Style()
                            .backgroundColor("#FF0000")
                            .size(Size().width(50%).height(75%))
                            .flex(Flex().alignSelf(.center))
                    )
                ],
                style: Style()
                    .backgroundColor("#00FF00")
                    .flex(Flex().justifyContent(.center))
            )
        )

        let viewController = BeagleScreenViewController(component)
        assertSnapshotImage(viewController, size: .custom(CGSize(width: 200, height: 150)))
    }
    
    func test_navigationBarButtonItemWithImage() {
        let dependencies = BeagleDependencies()
        dependencies.appBundle = Bundle(for: ScreenComponentTests.self)
        Beagle.dependencies = dependencies
        addTeardownBlock {
            Beagle.dependencies = BeagleDependencies()
        }
        
        let barItem = NavigationBarItem(image: "shuttle", text: "shuttle", action: ActionDummy())
        
        let component = Screen(
            safeArea: SafeArea.none,
            navigationBar: .init(title: "title", showBackButton: true, navigationBarItems: [barItem]),
            child: Text(text: "")
        )
        
        let viewController = BeagleScreenViewController(component)
        assertSnapshotImage(viewController, size: .custom(CGSize(width: 300, height: 200)))
    }
    
    func test_navigationBarButtonItemWithText() {
        let barItem = NavigationBarItem(text: "shuttle", action: ActionDummy())
        
        let component = Screen(
            safeArea: SafeArea.all,
            navigationBar: .init(title: "title", showBackButton: true, navigationBarItems: [barItem]),
            child: Text(text: "test")
        )
        
        let viewController = BeagleScreenViewController(component)
        assertSnapshotImage(viewController, size: .custom(CGSize(width: 300, height: 200)))
    }
    
    func testNavigationBarItemWithContextOnImage() {
        // Given
        let dependencies = BeagleDependencies()
        dependencies.appBundle = Bundle(for: ScreenComponentTests.self)
        
        let barItem = NavigationBarItem(image: "@{image}", text: "", action: ActionDummy())
        
        let screen = Screen(
            safeArea: SafeArea.all,
            navigationBar: .init(title: "title", showBackButton: true, navigationBarItems: [barItem]),
            child: Text(text: "test"),
            context: Context(id: "image", value: "shuttle")
        )
        
        // When
        let controller = BeagleScreenViewController(viewModel: .init(
            screenType: .declarative(screen),
            dependencies: dependencies
        ))
        
        // Then
        assertSnapshotImage(controller.view, size: .custom(CGSize(width: 150, height: 80)))
    }

    func test_action_shouldBeTriggered() {
        // Given
        let action = ActionSpy()
        let barItem = NavigationBarItem(text: "shuttle", action: action)
        let controller = BeagleScreenViewController(ComponentDummy())
        let navigation = BeagleNavigationController()
        navigation.viewControllers = [controller]
        _ = controller.view
        
        // When
        let resultingView = barItem.toBarButtonItem(controller: controller)
        _ = resultingView.target?.perform(resultingView.action)
        
        // Then
        XCTAssertEqual(action.executionCount, 1)
    }
    
    func test_shouldPrefetchNavigateAction() {
        let prefetch = BeaglePrefetchHelpingSpy()
        let dependencies = BeagleScreenDependencies(preFetchHelper: prefetch)
        let controller = BeagleControllerStub(dependencies: dependencies)
        let renderer = BeagleRenderer(controller: controller)
        
        let navigatePath = "button-item-prefetch"
        let navigate = Navigate.pushView(.remote(.init(url: "\(navigatePath)", shouldPrefetch: true)))
        let barItem = NavigationBarItem(text: "Item", action: navigate)
        let screen = Screen(
            navigationBar: NavigationBar(title: "Prefetch", navigationBarItems: [barItem]),
            child: ComponentDummy()
        )
        
        _ = renderer.render(screen)
        XCTAssertEqual([navigatePath], prefetch.prefetched)
    }
    
}
