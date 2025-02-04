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

import Foundation

public protocol DependencyDecoder {
    var decoder: ComponentDecoding { get }
}

public protocol ComponentDecoding {
    typealias Error = ComponentDecodingError
    
    func register<T: ServerDrivenComponent>(component type: T.Type)
    func register<A: Action>(action type: A.Type)
    
    func register<T: ServerDrivenComponent>(component type: T.Type, named: String)
    func register<A: Action>(action type: A.Type, named: String)
    
    func componentType(forType type: String) -> Decodable.Type?
    func actionType(forType type: String) -> Decodable.Type?
    
    func decodeComponent(from data: Data) throws -> ServerDrivenComponent
    func decodeAction(from data: Data) throws -> Action
    
    func nameForComponent(ofType type: ServerDrivenComponent.Type) -> String?
    func nameForAction(ofType type: Action.Type) -> String?
}

public enum ComponentDecodingError: Error {
    case couldNotCastToType(String)
}

final public class ComponentDecoder: ComponentDecoding {
    
    // MARK: - Dependencies
    
    private let jsonDecoder = JSONDecoder()
    
    private enum Namespace: String {
        case beagle
        case custom
    }
    
    private(set) var componentDecoders: [String: Decodable.Type] = [:]
    private(set) var actionDecoders: [String: Decodable.Type] = [:]
    
    // MARK: - Initialization
    
    public init() {
        registerDefaultTypes()
    }
    
    // MARK: - ComponentDecoding
    
    public func register<T: ServerDrivenComponent>(component type: T.Type) {
        let componentTypeName = String(describing: T.self)
        registerComponent(type, key: key(name: componentTypeName, namespace: .custom))
    }
    
    public func register<A: Action>(action type: A.Type) {
        let actionTypeName = String(describing: A.self)
        registerAction(type, key: key(name: actionTypeName, namespace: .custom))
    }
    
    public func register<T: ServerDrivenComponent>(component type: T.Type, named: String) {
        registerComponent(type, key: key(name: named, namespace: .custom))
    }
    
    public func register<A: Action>(action type: A.Type, named: String) {
        registerAction(type, key: key(name: named, namespace: .custom))
    }
    
    public func componentType(forType type: String) -> Decodable.Type? {
        return componentDecoders[type.lowercased()]
    }
    
    public func actionType(forType type: String) -> Decodable.Type? {
        return actionDecoders[type.lowercased()]
    }
    
    public func decodeComponent(from data: Data) throws -> ServerDrivenComponent {
        return try decodeAndLog(from: data)
    }
    
    public func decodeAction(from data: Data) throws -> Action {
        return try decodeAndLog(from: data)
    }
    
    public func nameForComponent(ofType type: ServerDrivenComponent.Type) -> String? {
        return componentDecoders.first { $0.value == type }?.key
    }
    
    public func nameForAction(ofType type: Action.Type) -> String? {
        return actionDecoders.first { $0.value == type }?.key
    }
    
    // MARK: - Private Functions

    private func decodeAndLog<T>(from data: Data) throws -> T {
        do {
            return try decode(from: data)
        } catch let error as DecodingError {
            dependencies.logger.log(Log.decode(.decodingError(type: String(describing: error))))
            throw error
        } catch {
            dependencies.logger.log(Log.decode(.decodingError(type: error.localizedDescription)))
            throw error
        }
    }

    private func decode<T>(from data: Data) throws -> T {
        let container = try jsonDecoder.decode(AnyDecodableContainer.self, from: data)
        guard let content = container.content as? T else {
            throw ComponentDecodingError.couldNotCastToType(String(describing: T.self))
        }
        return content
    }
    
    private func key(
        name: String,
        namespace: Namespace
    ) -> String {
        return "\(namespace):\(name)".lowercased()
    }
    
    // MARK: - Default Types Registration
    
    private func registerDefaultTypes() {
        registerActions()
        registerCoreTypes()
        registerFormModels()
        registerLayoutTypes()
        registerUITypes()
    }
    
    private func registerActions() {
        registerAction(Navigate.self, key: key(name: "OpenExternalURL", namespace: .beagle))
        registerAction(Navigate.self, key: key(name: "OpenNativeRoute", namespace: .beagle))
        registerAction(Navigate.self, key: key(name: "ResetApplication", namespace: .beagle))
        registerAction(Navigate.self, key: key(name: "ResetStack", namespace: .beagle))
        registerAction(Navigate.self, key: key(name: "PushStack", namespace: .beagle))
        registerAction(Navigate.self, key: key(name: "PopStack", namespace: .beagle))
        registerAction(Navigate.self, key: key(name: "PushView", namespace: .beagle))
        registerAction(Navigate.self, key: key(name: "PopView", namespace: .beagle))
        registerAction(Navigate.self, key: key(name: "PopToView", namespace: .beagle))
        registerAction(SetContext.self, key: key(name: "SetContext", namespace: .beagle))
        registerAction(SendRequest.self, key: key(name: "SendRequest", namespace: .beagle))
        registerAction(Alert.self, key: key(name: "Alert", namespace: .beagle))
        registerAction(Confirm.self, key: key(name: "Confirm", namespace: .beagle))
        registerAction(Condition.self, key: key(name: "Condition", namespace: .beagle))
        registerAction(SubmitForm.self, key: key(name: "SubmitForm", namespace: .beagle))
        registerAction(AddChildren.self, key: key(name: "AddChildren", namespace: .beagle))
    }
    
    private func registerCoreTypes() {
        registerComponent(Container.self, key: key(name: "Container", namespace: .beagle))
        registerComponent(Touchable.self, key: key(name: "Touchable", namespace: .beagle))
    }
    
    private func registerFormModels() {
        registerComponent(SimpleForm.self, key: key(name: "SimpleForm", namespace: .beagle))
    }
    
    private func registerLayoutTypes() {
        registerComponent(Screen.self, key: key(name: "ScreenComponent", namespace: .beagle))
        registerComponent(ScrollView.self, key: key(name: "ScrollView", namespace: .beagle))
    }
    
    private func registerUITypes() {
        registerComponent(Button.self, key: key(name: "Button", namespace: .beagle))
        registerComponent(Image.self, key: key(name: "Image", namespace: .beagle))
        registerComponent(ListView.self, key: key(name: "ListView", namespace: .beagle))
        registerComponent(GridView.self, key: key(name: "GridView", namespace: .beagle))
        registerComponent(Text.self, key: key(name: "Text", namespace: .beagle))
        registerComponent(PageView.self, key: key(name: "PageView", namespace: .beagle))
        registerComponent(TabBar.self, key: key(name: "TabBar", namespace: .beagle))
        registerComponent(PageIndicator.self, key: key(name: "PageIndicator", namespace: .beagle))
        registerComponent(LazyComponent.self, key: key(name: "LazyComponent", namespace: .beagle))
        registerComponent(WebView.self, key: key(name: "WebView", namespace: .beagle))
        registerComponent(TextInput.self, key: key(name: "TextInput", namespace: .beagle))
        registerComponent(PullToRefresh.self, key: key(name: "PullToRefresh", namespace: .beagle))
    }
    
    private func registerComponent<T: Decodable>(_ type: T.Type, key: String) {
        componentDecoders[key.lowercased()] = type
    }
    
    private func registerAction<T: Decodable>(_ type: T.Type, key: String) {
        actionDecoders[key.lowercased()] = type
    }
}
