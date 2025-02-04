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

/// Handles screens navigations actions of the application.
public enum Navigate: Action {
    
    /// Opens up an available browser on the device and navigates to a specified URL as Expression.
    case openExternalURL(Expression<String>, analytics: ActionAnalyticsConfig? = nil)
    
    /// Opens a screen that is defined completely local in your app (does not depend on Beagle) which will be retrieved using `DeeplinkScreenManager`.
    case openNativeRoute(OpenNativeRoute, analytics: ActionAnalyticsConfig? = nil)

    /// Resets the application's root navigation stack with a new navigation stack that has `Route` as the first view
    case resetApplication(Route, controllerId: String? = nil, navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    /// Resets the views stack to create a new flow with the passed route.
    case resetStack(Route, navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    /// Presents a new screen that comes from a specified route starting a new flow.
    /// You can specify a controllerId, describing the id of navigation controller used for the new flow.
    case pushStack(Route, controllerId: String? = nil, navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    /// Unstacks the current view stack.
    case popStack(navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)

    /// Opens a new screen for the given route and stacks that at the top of the hierarchy.
    case pushView(Route, navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    /// Dismisses the current view.
    case popView(navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    /// Returns the stack of screens in the application flow for a given screen in a route specified as String.
    case popToView(Expression<String>, navigationContext: NavigationContext? = nil, analytics: ActionAnalyticsConfig? = nil)
    
    public struct OpenNativeRoute {
        
        /// Deeplink identifier.
        public let route: Expression<String>
        
        /// Data that could be passed between screens.
        public let data: [String: String]?
        
        /// Allows customization of the behavior of restarting the application view stack.
        public let shouldResetApplication: Bool

        public init(
            route: StringOrExpression,
            data: [String: String]? = nil,
            shouldResetApplication: Bool = false
        ) {
            self.route = Expression(stringLiteral: route)
            self.data = data
            self.shouldResetApplication = shouldResetApplication
        }
    }
    
    public var analytics: ActionAnalyticsConfig? {
        switch self {
        case .openExternalURL(_, analytics: let analytics),
             .openNativeRoute(_, analytics: let analytics),
             .resetApplication(_, _, _, analytics: let analytics),
             .resetStack(_, _, analytics: let analytics),
             .pushStack(_, _, _, analytics: let analytics),
             .popStack(_, analytics: let analytics),
             .pushView(_, _, analytics: let analytics),
             .popView(_, analytics: let analytics),
             .popToView(_, _, analytics: let analytics):
            return analytics
        }
    }
    
}

public struct NavigationContext {
    public var path: Path?
    public var value: DynamicObject
    
    static let id = "navigationContext"
}

extension NavigationContext: CustomReflectable {
    public var customMirror: Mirror {
        return Mirror(
            self,
            children: [
                "path": path?.rawValue as Any,
                "value": value
            ],
            displayStyle: .struct
        )
    }
}

extension NavigationContext: Decodable { }

/// Defines a navigation route type which can be `remote` or `declarative`.
public enum Route {
    
    /// Navigates to a remote content on a specified path.
    case remote(NewPath)
    
    /// Navigates to a specified screen.
    case declarative(Screen)
}

extension Route {
    
    /// Constructs a new path to a remote screen.
    public struct NewPath {
        
        /// Contains the navigation endpoint.
        public let url: Expression<String>
        
        /// Changes _when_ this screen is requested.
        ///
        /// - If __false__, Beagle will only request this screen when the Navigate action gets triggered (e.g: user taps a button).
        /// - If __true__, Beagle will trigger the request as soon as it renders the component that have
        /// this action. (e.g: when a button appears on the screen it will trigger)
        public var shouldPrefetch: Bool?
        
        /// A screen that should be rendered in case of request fail.
        public var fallback: Screen?

        /// Used to pass additional http data on requests
        public var httpAdditionalData: HttpAdditionalData?

    }
}

extension Route.NewPath {

    /// RouteAdditionalData can be used on navigate actions to pass additional http data on requests triggered by Beagle.
    public struct HttpAdditionalData: AutoDecodable {
        public var method: HTTPMethod? = .get
        public var headers: [String: String]? = [:]
        public var body: DynamicObject?
    }
}

// MARK: Decodable

extension Navigate.OpenNativeRoute: Decodable {}

extension Navigate: Decodable, CustomReflectable {
    
    enum CodingKeys: CodingKey {
        case _beagleAction_
        case analytics
        case route
        case url
        case controllerId
        case navigationContext
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: ._beagleAction_)
        let analytics = try container.decodeIfPresent(ActionAnalyticsConfig.self, forKey: .analytics)
        let navigationContext = try container.decodeIfPresent(NavigationContext.self, forKey: .navigationContext)
        switch type.lowercased() {
        case "beagle:openexternalurl":
            self = .openExternalURL(try container.decode(Expression<String>.self, forKey: .url), analytics: analytics)
        case "beagle:opennativeroute":
            self = .openNativeRoute(try .init(from: decoder), analytics: analytics)
        case "beagle:resetapplication":
            self = .resetApplication(
                try container.decode(Route.self, forKey: .route),
                controllerId: try container.decodeIfPresent(String.self, forKey: .controllerId),
                navigationContext: navigationContext,
                analytics: analytics
            )
        case "beagle:resetstack":
            self = .resetStack(try container.decode(Route.self, forKey: .route), navigationContext: navigationContext, analytics: analytics)
        case "beagle:pushstack":
            self = .pushStack(
                try container.decode(Route.self, forKey: .route),
                controllerId: try container.decodeIfPresent(String.self, forKey: .controllerId),
                navigationContext: navigationContext,
                analytics: analytics
            )
        case "beagle:popstack":
            self = .popStack(navigationContext: navigationContext, analytics: analytics)
        case "beagle:pushview":
            self = .pushView(try container.decode(Route.self, forKey: .route), navigationContext: navigationContext, analytics: analytics)
        case "beagle:popview":
            self = .popView(navigationContext: navigationContext, analytics: analytics)
        case "beagle:poptoview":
            self = .popToView(
                try container.decode(Expression<String>.self, forKey: .route),
                navigationContext: navigationContext,
                analytics: analytics
            )
        default:
            throw DecodingError.dataCorruptedError(forKey: ._beagleAction_,
                                                   in: container,
                                                   debugDescription: "Can't decode '\(type)'")
        }
    }

    public var customMirror: Mirror {
        let children: [Mirror.Child]
        switch self {
        case let .openExternalURL(url, analytics: analytics):
            children = [
                (label: CodingKeys._beagleAction_.stringValue, value: "beagle:openexternalurl"),
                (label: CodingKeys.analytics.stringValue, value: analytics as Any),
                (label: CodingKeys.url.stringValue, value: url)
            ]
        case let .openNativeRoute(nativeRoute, analytics: analytics):
            children = [
                (label: CodingKeys._beagleAction_.stringValue, value: "beagle:opennativeroute"),
                (label: CodingKeys.analytics.stringValue, value: analytics as Any)
            ] + Mirror(reflecting: nativeRoute).children
        case let .resetApplication(route, controllerId: controllerId, navigationContext: navigationContext, analytics: analytics):
            children = [
                (label: CodingKeys._beagleAction_.stringValue, value: "beagle:resetapplication"),
                (label: CodingKeys.analytics.stringValue, value: analytics as Any),
                (label: CodingKeys.navigationContext.stringValue, value: navigationContext as Any),
                (label: CodingKeys.route.stringValue, value: route),
                (label: CodingKeys.controllerId.stringValue, value: controllerId as Any)
            ]
        case let .resetStack(route, navigationContext: navigationContext, analytics: analytics):
            children = [
                (label: CodingKeys._beagleAction_.stringValue, value: "beagle:resetstack"),
                (label: CodingKeys.analytics.stringValue, value: analytics as Any),
                (label: CodingKeys.navigationContext.stringValue, value: navigationContext as Any),
                (label: CodingKeys.route.stringValue, value: route)
            ]
        case let .pushStack(route, controllerId: controllerId, navigationContext: navigationContext, analytics: analytics):
            children = [
                (label: CodingKeys._beagleAction_.stringValue, value: "beagle:pushstack"),
                (label: CodingKeys.analytics.stringValue, value: analytics as Any),
                (label: CodingKeys.navigationContext.stringValue, value: navigationContext as Any),
                (label: CodingKeys.route.stringValue, value: route),
                (label: CodingKeys.controllerId.stringValue, value: controllerId as Any)
            ]
        case let .popStack(navigationContext: navigationContext, analytics: analytics):
            children = [
                (label: CodingKeys._beagleAction_.stringValue, value: "beagle:popstack"),
                (label: CodingKeys.analytics.stringValue, value: analytics as Any),
                (label: CodingKeys.navigationContext.stringValue, value: navigationContext as Any)
            ]
        case let .pushView(route, navigationContext: navigationContext, analytics: analytics):
            children = [
                (label: CodingKeys._beagleAction_.stringValue, value: "beagle:pushview"),
                (label: CodingKeys.analytics.stringValue, value: analytics as Any),
                (label: CodingKeys.navigationContext.stringValue, value: navigationContext as Any),
                (label: CodingKeys.route.stringValue, value: route)
            ]
        case let .popView(navigationContext: navigationContext, analytics: analytics):
            children = [
                (label: CodingKeys._beagleAction_.stringValue, value: "beagle:popview"),
                (label: CodingKeys.analytics.stringValue, value: analytics as Any),
                (label: CodingKeys.navigationContext.stringValue, value: navigationContext as Any)
            ]
        case let .popToView(route, navigationContext: navigationContext, analytics: analytics):
            children = [
                (label: CodingKeys._beagleAction_.stringValue, value: "beagle:poptoview"),
                (label: CodingKeys.analytics.stringValue, value: analytics as Any),
                (label: CodingKeys.navigationContext.stringValue, value: navigationContext as Any),
                (label: CodingKeys.route.stringValue, value: route)
            ]
        }
        return Mirror(self, children: children, displayStyle: .struct)
    }
}

extension Route: Decodable, CustomReflectable {
    
    enum CodingKeys: CodingKey {
        case type
        case path
        case shouldPrefetch
        case screen
        case data
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let screen = try? container.decode(Screen.self, forKey: .screen) {
            self = .declarative(screen)
        } else {
            let newPath: Route.NewPath = try .init(from: decoder)
            self = .remote(newPath)
        }
    }

    public var customMirror: Mirror {
        switch self {
        case .remote(let newPath):
            return Mirror(
                self,
                children: Mirror(reflecting: newPath).children,
                displayStyle: .struct
            )
        case .declarative(let screen):
            return Mirror(
                self,
                children: [CodingKeys.screen.stringValue: screen],
                displayStyle: .struct
            )
        }
    }
}

extension Route.NewPath: Decodable {
    
    enum CodingKeys: CodingKey {
        case url
        case shouldPrefetch
        case fallback
        case httpAdditionalData
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decode(Expression<String>.self, forKey: .url)
        self.shouldPrefetch = try container.decodeIfPresent(Bool.self, forKey: .shouldPrefetch)
        self.fallback = try container.decodeIfPresent(Screen.self, forKey: .fallback)
        self.httpAdditionalData = try container.decodeIfPresent(HttpAdditionalData.self, forKey: .httpAdditionalData)
    }
}
