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

/// TabBar is a component responsible to display a tab layout.
/// It works by displaying tabs that can change a context when clicked.
public struct TabBar: ServerDrivenComponent, AutoDecodable {
    
    /// Defines yours tabs title and icon.
    public let items: [TabBarItem]
    
    /// Reference a native style configured to be applied on this view.
    public var styleId: String?
    
    /// Defines the expression that is observed to change the current tab selected.
    public var currentTab: Expression<Int>?
    
    /// Defines a list of action that will be executed when a tab is selected.
    public var onTabSelection: [Action]?

}

/// Defines the view item in the tab view
public struct TabBarItem {
    
    /// Displays the text on the `TabView` component. If it is null or not declared it won't display any text.
    public var icon: StringOrExpression?
    
    /// Display an icon image on the `TabView` component.
    /// If it is left as null or not declared it won't display any icon.
    public var title: String?
    
}

extension TabBarItem: Decodable {
    enum CodingKeys: String, CodingKey {
        case icon
        case title
    }
    
    enum LocalImageCodingKey: String, CodingKey {
        case mobileId
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nestedContainer = try? container.nestedContainer(keyedBy: LocalImageCodingKey.self, forKey: .icon)
        icon = try nestedContainer?.decodeIfPresent(String.self, forKey: .mobileId)
        title = try container.decodeIfPresent(String.self, forKey: .title)
    }
}
