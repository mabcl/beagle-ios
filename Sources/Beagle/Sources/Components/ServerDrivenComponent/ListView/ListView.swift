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

/// ListView is a Layout component that will define a list of views natively. These views could be any ServerDrivenComponent.
public struct ListView: Widget, HasContext, InitiableComponent {
    
    public typealias Direction = ScrollAxis
    
    /// Defines the context of the component.
    public var context: Context?
    
    /// Allows to define a list of actions to be performed when the ListView is displayed.
    public var onInit: [Action]?
    
    /// It's an expression that points to a list of values used to populate the ListView.
    public let dataSource: Expression<[DynamicObject]>
    
    /// Points to a unique value present in each dataSource item used as a suffix in the component ids within the ListView.
    public var key: String?
    
    /// Direction of the list scroll.
    public var direction: Direction?
    
    /// Templates available to the list items.
    /// The list will use the first template which matches the `Template.case`.
    /// When there is no match, the first template without a `case` will be used.
    public var templates: [Template] = []
    
    /// Is the context identifier of each cell.
    public var iteratorName: String?
    
    /// List of actions performed when the list is scrolled to the end.
    public var onScrollEnd: [Action]?
    
    /// Sets the scrolled percentage of the list to trigger onScrollEnd.
    public var scrollEndThreshold: Int?
    
    /// This attribute enables or disables the scroll indicator.
    public var isScrollIndicatorVisible: Bool?
    
    public var id: String?
    public var style: Style?
    public var accessibility: Accessibility?
        
}

public struct Template: AutoDecodable {

    public var `case`: Expression<Bool>?
    
    public let view: ServerDrivenComponent

}

extension ListView: Decodable {

    enum CodingKeys: String, CodingKey {
        case children
        case context
        case onInit
        case dataSource
        case key
        case direction
        case template
        case templates
        case iteratorName
        case onScrollEnd
        case scrollEndThreshold
        case isScrollIndicatorVisible
        case id
        case style
        case accessibility
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.iteratorName = try container.decodeIfPresent(String.self, forKey: .iteratorName)
        self.direction = try container.decodeIfPresent(Direction.self, forKey: .direction)
        
        key = try container.decodeIfPresent(String.self, forKey: .key)
        context = try container.decodeIfPresent(Context.self, forKey: .context)
        onInit = try container.decodeIfPresent(forKey: .onInit)
        onScrollEnd = try container.decodeIfPresent(forKey: .onScrollEnd)
        scrollEndThreshold = try container.decodeIfPresent(Int.self, forKey: .scrollEndThreshold)
        isScrollIndicatorVisible = try container.decodeIfPresent(Bool.self, forKey: .isScrollIndicatorVisible)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        style = try container.decodeIfPresent(Style.self, forKey: .style) ?? Style()
        accessibility = try container.decodeIfPresent(Accessibility.self, forKey: .accessibility)
        
        self.templates = try container.decodeIfPresent([Template].self, forKey: .templates) ?? []
        self.dataSource = try container.decode(Expression<[DynamicObject]>.self, forKey: .dataSource)
        
    }
}
