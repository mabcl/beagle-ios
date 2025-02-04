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
@testable import Beagle

class AutoLayoutWrapperTests: XCTestCase {
    
    let size = ImageSize.custom(CGSize(width: 200, height: 200))
    let defaultStyle = Style().backgroundColor("#00FFFF").margin(EdgeValue(all: 5)).padding(EdgeValue(all: 5))
    
    func testWrapperViewWithDefault() { // column and noWrap
        // Given
        let component = Container(
            children: [
                Text(text: "Yoga"),
                AutoLayoutComponent(),
                AutoLayoutComponent()
            ],
            style: defaultStyle
        )
        let viewController = BeagleScreenViewController(component)
        
        // When/ Then
        assertSnapshotImage(viewController, size: size)
    }
    
    func testWrapperViewWithColumnAndWrap() {
        // Given
        let component = Container(
            children: [
                Text(text: "Yoga"),
                AutoLayoutComponent(),
                AutoLayoutComponent()
            ],
            style: defaultStyle.flex(Flex().flexDirection(.column).flexWrap(.wrap))
        )
        let viewController = BeagleScreenViewController(component)
        
        // When/ Then
        assertSnapshotImage(viewController, size: size)
    }
    
    func testWrapperViewWithRowAndNoWrap() {
        // Given
        let component = Container(
            children: [
                Text(text: "Yoga"),
                AutoLayoutComponent(),
                AutoLayoutComponent(),
                AutoLayoutComponent()
            ],
            style: defaultStyle.flex(Flex().flexDirection(.row).flexWrap(.noWrap))
        )
        let viewController = BeagleScreenViewController(component)
        
        // When/ Then
        assertSnapshotImage(viewController, size: size)
    }
    
    func testWrapperViewWithRowAndWrap() {
        // Given
        let component = Container(
            children: [
                Text(text: "Yoga"),
                AutoLayoutComponent(),
                AutoLayoutComponent(),
                AutoLayoutComponent()
            ],
            style: defaultStyle.flex(Flex().flexDirection(.row).flexWrap(.wrap))
        )
        let viewController = BeagleScreenViewController(component)
        
        // When/ Then
        assertSnapshotImage(viewController, size: size)
    }
    
    func testWrapperViewResizing() {
        // Given
        let component = Container(
            children: [
                Text(text: "Yoga"),
                AutoLayoutComponent()
            ],
            id: "container",
            style: defaultStyle.flex(Flex().flexDirection(.row))
        )
        let viewController = BeagleScreenViewController(component)
        
        // When/ Then
        assertSnapshotImage(viewController, size: size)
        viewController.execute(actions: [AddChildren(componentId: "container", value: [AutoLayoutComponent()])], event: nil, origin: UIView())
        assertSnapshotImage(viewController, size: size)
    }
    
}

struct AutoLayoutComponent: Widget {
    var id: String?
    var style: Style?
    var accessibility: Accessibility?
    
    func toView(renderer: BeagleRenderer) -> UIView {
        return AutoLayoutWrapper(view: AutoLayoutSample())
    }
}

class AutoLayoutSample: UIView {
    
    override init(frame: CGRect) {
        let view = UIView()
        super.init(frame: frame)
        
        backgroundColor = .yellow
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        
        view.backgroundColor = .cyan
        addSubview(view)
    
        let label = UILabel()
        label.text = "AUTO"
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        label.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
        view.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5).isActive = true
        view.widthAnchor.constraint(equalToConstant: 50).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        view.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
