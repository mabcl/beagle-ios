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

final class ButtonTests: XCTestCase {
    
    private let snapshotSize = CGSize(width: 150, height: 50)
    private lazy var theme = AppTheme(
        styles: [
           "test.button.style": buttonStyle
        ]
    )
    
    private lazy var dependencies = BeagleScreenDependencies(theme: theme)
    private lazy var controller = BeagleControllerStub(dependencies: dependencies)
    private lazy var renderer = BeagleRenderer(controller: controller)

    private func buttonStyle() -> (UIButton?) -> Void {
        return {
            $0?.layer.cornerRadius = 4
            $0?.setTitleColor(.white, for: .normal)
            $0?.backgroundColor = ($0?.isEnabled ?? false) ? .green : .gray
            $0?.alpha = $0?.isHighlighted ?? false ? 0.7 : 1
        }
    }
    
    func testDecodingButton() throws {
        let component: Button = try componentFromJsonFile(fileName: "buttonComponent")
        assertSnapshot(matching: component, as: .dump)
    }
    
    func testSetRightButtonTitle() {
        //Given
        let buttonTitle = "title"
        let component = Button(text: Expression.value(buttonTitle))
        
        //When
        let button = renderer.render(component) as? UIButton
        
        // Then
        XCTAssertEqual(button?.titleLabel?.text, buttonTitle)
    }

    func testSetEnabledState() throws {
        try buttonShouldBeProperlySetWith(enabled: true)
        try buttonShouldBeProperlySetWith(enabled: false)
        try buttonShouldBeProperlySetWith(enabled: nil)
    }

    private func buttonShouldBeProperlySetWith(enabled: Bool?) throws {
        // Given
        let component = Button(text: "", enabled: enabled.map { .value($0) })

        // When
        let button = try XCTUnwrap(renderer.render(component) as? UIButton)

        // Then
        XCTAssertEqual(button.isEnabled, enabled ?? true)
    }
    
    func testApplyButtonStyle() {
        // Given
        let theme = ThemeSpy()
        controller.dependencies = BeagleScreenDependencies(theme: theme)
        
        let style = "test.button.style"
        let button = Button(text: "apply style", styleId: style)

        // When
        let view = renderer.render(button)

        // Then
        XCTAssertEqual(view, theme.styledView)
        XCTAssertEqual(style, theme.styleApplied)
    }
    
    func testPrefetchNavigateAction() {
        // Given
        let prefetch = BeaglePrefetchHelpingSpy()
        controller.dependencies = BeagleScreenDependencies(preFetchHelper: prefetch)
        
        let navigatePath = "path-to-prefetch"
        let navigate = Navigate.pushStack(.remote(.init(url: "\(navigatePath)")))
        let button = Button(text: "prefetch", onPress: [navigate])

        // When
        _ = renderer.render(button)

        // Then
        XCTAssertEqual([navigatePath], prefetch.prefetched)
    }
    
    func testActionTriggered() {
        // Given
        let action = ActionSpy()
        let button = Button(text: "Trigger Action", onPress: [action])

        // When
        let view = renderer.render(button) as? Button.BeagleUIButton
        view?.triggerTouchUpInsideActions()

        // Then
        XCTAssertEqual(action.executionCount, 1)
        XCTAssert(action.lastOrigin as AnyObject === view)
    }
    
    func testRenderDefaultButtonComponent() {
        // Given
        let button = Button(text: "Default Button")

        // When
        let view = renderer.render(button)
        
        // Then
        assertSnapshotImage(view, size: .custom(snapshotSize))
    }
    
    func testRenderCustomButtonComponent() {
        // Given
        let style = "test.button.style"
        let button = Button(text: "Custom Button", styleId: style)

        // When
        let view = renderer.render(button)
        
        // Then
        assertSnapshotImage(view, size: .custom(snapshotSize))
    }
}
