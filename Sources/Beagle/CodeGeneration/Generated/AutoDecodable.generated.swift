// Generated using Sourcery 1.4.2 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
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

// MARK: Alert Decodable
extension Alert {

    enum CodingKeys: String, CodingKey {
        case title
        case message
        case onPressOk
        case labelOk
        case analytics
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decodeIfPresent(Expression<String>.self, forKey: .title)
        message = try container.decode(Expression<String>.self, forKey: .message)
        onPressOk = try container.decodeIfPresent(forKey: .onPressOk)
        labelOk = try container.decodeIfPresent(String.self, forKey: .labelOk)
        analytics = try container.decodeIfPresent(ActionAnalyticsConfig.self, forKey: .analytics)
    }
}

// MARK: Button Decodable
extension Button {

    enum CodingKeys: String, CodingKey {
        case text
        case styleId
        case onPress
        case enabled
        case id
        case style
        case accessibility
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        text = try container.decode(Expression<String>.self, forKey: .text)
        styleId = try container.decodeIfPresent(String.self, forKey: .styleId)
        onPress = try container.decodeIfPresent(forKey: .onPress)
        enabled = try container.decodeIfPresent(Expression<Bool>.self, forKey: .enabled)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        style = try container.decodeIfPresent(Style.self, forKey: .style)
        accessibility = try container.decodeIfPresent(Accessibility.self, forKey: .accessibility)
    }
}

// MARK: Condition Decodable
extension Condition {

    enum CodingKeys: String, CodingKey {
        case condition
        case onTrue
        case onFalse
        case analytics
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        condition = try container.decode(Expression<Bool>.self, forKey: .condition)
        onTrue = try container.decodeIfPresent(forKey: .onTrue)
        onFalse = try container.decodeIfPresent(forKey: .onFalse)
        analytics = try container.decodeIfPresent(ActionAnalyticsConfig.self, forKey: .analytics)
    }
}

// MARK: Confirm Decodable
extension Confirm {

    enum CodingKeys: String, CodingKey {
        case title
        case message
        case onPressOk
        case onPressCancel
        case labelOk
        case labelCancel
        case analytics
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decodeIfPresent(Expression<String>.self, forKey: .title)
        message = try container.decode(Expression<String>.self, forKey: .message)
        onPressOk = try container.decodeIfPresent(forKey: .onPressOk)
        onPressCancel = try container.decodeIfPresent(forKey: .onPressCancel)
        labelOk = try container.decodeIfPresent(String.self, forKey: .labelOk)
        labelCancel = try container.decodeIfPresent(String.self, forKey: .labelCancel)
        analytics = try container.decodeIfPresent(ActionAnalyticsConfig.self, forKey: .analytics)
    }
}

// MARK: Container Decodable
extension Container {

    enum CodingKeys: String, CodingKey {
        case children
        case onInit
        case context
        case styleId
        case id
        case style
        case accessibility
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        children = try container.decodeIfPresent(forKey: .children)
        onInit = try container.decodeIfPresent(forKey: .onInit)
        context = try container.decodeIfPresent(Context.self, forKey: .context)
        styleId = try container.decodeIfPresent(String.self, forKey: .styleId)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        style = try container.decodeIfPresent(Style.self, forKey: .style)
        accessibility = try container.decodeIfPresent(Accessibility.self, forKey: .accessibility)
    }
}

// MARK: Context Decodable
extension Context {

    enum CodingKeys: String, CodingKey {
        case id
        case value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        value = try container.decode(DynamicObject.self, forKey: .value)
    }
}

// MARK: GridView Decodable
extension GridView {

    enum CodingKeys: String, CodingKey {
        case context
        case onInit
        case dataSource
        case key
        case direction
        case spanCount
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

        context = try container.decodeIfPresent(Context.self, forKey: .context)
        onInit = try container.decodeIfPresent(forKey: .onInit)
        dataSource = try container.decode(Expression<[DynamicObject]>.self, forKey: .dataSource)
        key = try container.decodeIfPresent(String.self, forKey: .key)
        direction = try container.decodeIfPresent(Direction.self, forKey: .direction)
        spanCount = try container.decode(Int.self, forKey: .spanCount)
        templates = try container.decode([Template].self, forKey: .templates)
        iteratorName = try container.decodeIfPresent(String.self, forKey: .iteratorName)
        onScrollEnd = try container.decodeIfPresent(forKey: .onScrollEnd)
        scrollEndThreshold = try container.decodeIfPresent(Int.self, forKey: .scrollEndThreshold)
        isScrollIndicatorVisible = try container.decodeIfPresent(Bool.self, forKey: .isScrollIndicatorVisible)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        style = try container.decodeIfPresent(Style.self, forKey: .style)
        accessibility = try container.decodeIfPresent(Accessibility.self, forKey: .accessibility)
    }
}

// MARK: LazyComponent Decodable
extension LazyComponent {

    enum CodingKeys: String, CodingKey {
        case path
        case initialState
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        path = try container.decode(String.self, forKey: .path)
        initialState = try container.decode(forKey: .initialState)
    }
}

// MARK: PageView Decodable
extension PageView {

    enum CodingKeys: String, CodingKey {
        case children
        case context
        case onPageChange
        case currentPage
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        children = try container.decodeIfPresent(forKey: .children)
        context = try container.decodeIfPresent(Context.self, forKey: .context)
        onPageChange = try container.decodeIfPresent(forKey: .onPageChange)
        currentPage = try container.decodeIfPresent(Expression<Int>.self, forKey: .currentPage)
    }
}

// MARK: PullToRefresh Decodable
extension PullToRefresh {

    enum CodingKeys: String, CodingKey {
        case context
        case onPull
        case isRefreshing
        case color
        case child
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        context = try container.decodeIfPresent(Context.self, forKey: .context)
        onPull = try container.decodeIfPresent(forKey: .onPull)
        isRefreshing = try container.decodeIfPresent(Expression<Bool>.self, forKey: .isRefreshing)
        color = try container.decodeIfPresent(Expression<String>.self, forKey: .color)
        child = try container.decode(forKey: .child)
    }
}

// MARK: Route.NewPath.HttpAdditionalData Decodable
extension Route.NewPath.HttpAdditionalData {

    enum CodingKeys: String, CodingKey {
        case method
        case headers
        case body
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        method = try container.decodeIfPresent(HTTPMethod.self, forKey: .method) ?? .get
        headers = try container.decodeIfPresent([String: String].self, forKey: .headers) ?? [:]
        body = try container.decodeIfPresent(DynamicObject.self, forKey: .body)
    }
}

// MARK: ScrollView Decodable
extension ScrollView {

    enum CodingKeys: String, CodingKey {
        case children
        case scrollDirection
        case scrollBarEnabled
        case context
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        children = try container.decodeIfPresent(forKey: .children)
        scrollDirection = try container.decodeIfPresent(ScrollAxis.self, forKey: .scrollDirection)
        scrollBarEnabled = try container.decodeIfPresent(Bool.self, forKey: .scrollBarEnabled)
        context = try container.decodeIfPresent(Context.self, forKey: .context)
    }
}

// MARK: SendRequest Decodable
extension SendRequest {

    enum CodingKeys: String, CodingKey {
        case url
        case method
        case data
        case headers
        case onSuccess
        case onError
        case onFinish
        case analytics
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        url = try container.decode(Expression<String>.self, forKey: .url)
        method = try container.decodeIfPresent(Expression<HTTPMethod>.self, forKey: .method)
        data = try container.decodeIfPresent(DynamicObject.self, forKey: .data)
        headers = try container.decodeIfPresent(Expression<[String: String]>.self, forKey: .headers)
        onSuccess = try container.decodeIfPresent(forKey: .onSuccess)
        onError = try container.decodeIfPresent(forKey: .onError)
        onFinish = try container.decodeIfPresent(forKey: .onFinish)
        analytics = try container.decodeIfPresent(ActionAnalyticsConfig.self, forKey: .analytics)
    }
}

// MARK: SimpleForm Decodable
extension SimpleForm {

    enum CodingKeys: String, CodingKey {
        case context
        case onSubmit
        case onValidationError
        case children
        case id
        case style
        case accessibility
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        context = try container.decodeIfPresent(Context.self, forKey: .context)
        onSubmit = try container.decodeIfPresent(forKey: .onSubmit)
        onValidationError = try container.decodeIfPresent(forKey: .onValidationError)
        children = try container.decodeIfPresent(forKey: .children)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        style = try container.decodeIfPresent(Style.self, forKey: .style)
        accessibility = try container.decodeIfPresent(Accessibility.self, forKey: .accessibility)
    }
}

// MARK: TabBar Decodable
extension TabBar {

    enum CodingKeys: String, CodingKey {
        case items
        case styleId
        case currentTab
        case onTabSelection
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        items = try container.decode([TabBarItem].self, forKey: .items)
        styleId = try container.decodeIfPresent(String.self, forKey: .styleId)
        currentTab = try container.decodeIfPresent(Expression<Int>.self, forKey: .currentTab)
        onTabSelection = try container.decodeIfPresent(forKey: .onTabSelection)
    }
}

// MARK: Template Decodable
extension Template {

    enum CodingKeys: String, CodingKey {
        case `case`
        case view
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        `case` = try container.decodeIfPresent(Expression<Bool>.self, forKey: .`case`)
        view = try container.decode(forKey: .view)
    }
}

// MARK: TextInput Decodable
extension TextInput {

    enum CodingKeys: String, CodingKey {
        case value
        case placeholder
        case enabled
        case readOnly
        case type
        case styleId
        case onChange
        case onBlur
        case onFocus
        case error
        case showError
        case id
        case style
        case accessibility
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        value = try container.decodeIfPresent(Expression<String>.self, forKey: .value)
        placeholder = try container.decodeIfPresent(Expression<String>.self, forKey: .placeholder)
        enabled = try container.decodeIfPresent(Expression<Bool>.self, forKey: .enabled)
        readOnly = try container.decodeIfPresent(Expression<Bool>.self, forKey: .readOnly)
        type = try container.decodeIfPresent(Expression<TextInputType>.self, forKey: .type)
        styleId = try container.decodeIfPresent(String.self, forKey: .styleId)
        onChange = try container.decodeIfPresent(forKey: .onChange)
        onBlur = try container.decodeIfPresent(forKey: .onBlur)
        onFocus = try container.decodeIfPresent(forKey: .onFocus)
        error = try container.decodeIfPresent(Expression<String>.self, forKey: .error)
        showError = try container.decodeIfPresent(Expression<Bool>.self, forKey: .showError)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        style = try container.decodeIfPresent(Style.self, forKey: .style)
        accessibility = try container.decodeIfPresent(Accessibility.self, forKey: .accessibility)
    }
}

// MARK: Touchable Decodable
extension Touchable {

    enum CodingKeys: String, CodingKey {
        case onPress
        case child
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        onPress = try container.decode(forKey: .onPress)
        child = try container.decode(forKey: .child)
    }
}

// MARK: WebView Decodable
extension WebView {

    enum CodingKeys: String, CodingKey {
        case url
        case id
        case style
        case accessibility
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        url = try container.decode(Expression<String>.self, forKey: .url)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        style = try container.decodeIfPresent(Style.self, forKey: .style)
        accessibility = try container.decodeIfPresent(Accessibility.self, forKey: .accessibility)
    }
}
