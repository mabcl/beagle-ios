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

final class BeagleSetupTests: XCTestCase {
    // swiftlint:disable discouraged_direct_init

    func testDefaultDependencies() {
        let dependencies = BeagleDependencies()
        dependencies.appBundle = Bundle()
        assertSnapshot(matching: dependencies, as: .dump)
    }

    func testChangedDependencies() {
        let dep = BeagleDependencies()
        dep.appBundle = Bundle()
        dep.deepLinkHandler = DeepLinkHandlerDummy()
        dep.theme = AppThemeDummy()
        if let url = URL(string: "www.test.com") {
            dep.urlBuilder.baseUrl = url
        }
        dep.networkClient = NetworkClientDummy()
        dep.style = { _ in return StyleViewConfiguratorDummy() }
        dep.decoder = ComponentDecodingDummy()
        dep.windowManager = WindowManagerDumb()
        dep.opener = URLOpenerDumb()
        dep.globalContext = GlobalContextDummy()
        dep.operationsProvider = OperationsProviderDummy()
        
        assertSnapshot(matching: dep, as: .dump)
    }

    func test_ifChangingDependency_othersShouldUseNewInstance() {
        let dependencies = BeagleDependencies()

        let themeSpy = ThemeSpy()
        dependencies.theme = themeSpy

        let view = UIView()
        let styleId = "custom-style"

        dependencies.theme.applyStyle(for: view, withId: styleId)

        XCTAssertEqual(themeSpy.styledView, view)
        XCTAssertEqual(themeSpy.styleApplied, styleId)
    }
}

// MARK: - Testing Helpers

final class DeepLinkHandlerDummy: DeepLinkScreenManaging {
    func getNativeScreen(with path: String, data: [String: String]?) throws -> UIViewController {
        return UIViewController()
    }
}

final class ComponentDecodingDummy: ComponentDecoding {
    func register<T>(component type: T.Type) where T: ServerDrivenComponent {}
    func register<A>(action type: A.Type) where A: Action {}
    func register<T>(component type: T.Type, named typeName: String) where T: ServerDrivenComponent {}
    func register<A>(action type: A.Type, named typeName: String) where A: Action {}
    func componentType(forType type: String) -> Decodable.Type? { return nil }
    func actionType(forType type: String) -> Decodable.Type? { return nil }
    func decodeComponent(from data: Data) throws -> ServerDrivenComponent { return ComponentDummy() }
    func decodeAction(from data: Data) throws -> Action { return ActionDummy() }
    func nameForComponent(ofType type: ServerDrivenComponent.Type) -> String? { return nil }
    func nameForAction(ofType type: Action.Type) -> String? { return nil }
}

final class PreFetchHelperDummy: BeaglePrefetchHelping {
    func prefetchComponent(newPath: Route.NewPath) { }
}

struct ComponentDummy: ServerDrivenComponent, CustomStringConvertible {
    
    private let resultView: UIView?
    
    var description: String {
        return "ComponentDummy()"
    }
    
    init(resultView: UIView? = nil) {
        self.resultView = resultView
    }
    
    init(from decoder: Decoder) throws {
        self.resultView = nil
    }
    
    func toView(renderer: BeagleRenderer) -> UIView {
        return resultView ?? UIView()
    }
}

struct ActionDummy: Action, Equatable {
    var analytics: ActionAnalyticsConfig?
    
    func execute(controller: BeagleController, origin: UIView) {}
}

struct BeagleScreenDependencies: BeagleDependenciesProtocol {
    var isLoggingEnabled: Bool = true
    var analyticsProvider: AnalyticsProvider?
    var viewClient: ViewClient = ViewClientStub()
    var imageDownloader: ImageDownloader = ImageDownloaderStub()
    var theme: Theme = AppThemeDummy()
    var preFetchHelper: BeaglePrefetchHelping = PreFetchHelperDummy()
    var appBundle: Bundle = Bundle(for: ImageTests.self)
    var decoder: ComponentDecoding = ComponentDecodingDummy()
    var logger: BeagleLoggerType = BeagleLoggerDumb()
    var navigationControllerType = BeagleNavigationController.self
    var urlBuilder: UrlBuilderProtocol = UrlBuilder()
    var networkClient: NetworkClient? = NetworkClientDummy()
    var deepLinkHandler: DeepLinkScreenManaging?
    var navigation: BeagleNavigation = BeagleNavigationDummy()
    var windowManager: WindowManager = WindowManagerDumb()
    var opener: URLOpener = URLOpenerDumb()
    var globalContext: GlobalContext = GlobalContextDummy()
    var operationsProvider: OperationsProvider = OperationsProviderDummy()

    var renderer: (BeagleController) -> BeagleRenderer = {
        return BeagleRenderer(controller: $0)
    }
    var viewConfigurator: (UIView) -> ViewConfiguratorProtocol = {
        return ViewConfigurator(view: $0)
    }
    var style: (UIView) -> StyleViewConfiguratorProtocol = { _ in
        return StyleViewConfiguratorDummy()
    }
}

class NetworkClientDummy: NetworkClient {
    func executeRequest(_ request: Request, completion: @escaping RequestCompletion) -> RequestToken? {
        return nil
    }
}

final class AppThemeDummy: Theme {
    func applyStyle<T>(for view: T, withId id: String) where T: UIView {
    }
}

class BeagleNavigationDummy: BeagleNavigation {
    
    var defaultAnimation: BeagleNavigatorAnimation?
    
    func navigate(action: Navigate, controller: BeagleController, animated: Bool, origin: UIView?) {
        // Intentionally unimplemented...
    }

    func registerDefaultNavigationController(builder: @escaping NavigationBuilder) {
        // Intentionally unimplemented...
    }

    func registerNavigationController(builder: @escaping NavigationBuilder, forId controllerId: String) {
        // Intentionally unimplemented...
    }

    func navigationController(forId controllerId: String?) -> BeagleNavigationController {
        return .init()
    }
}

class GlobalContextDummy: GlobalContext {
    let globalId: String = ""
    let context: Observable<Context> = Observable(value: .init(id: "", value: .empty))
    
    func isGlobal(id: String?) -> Bool { true }
    
    func set(value: DynamicObject, path: String?) {
        // Intentionally unimplemented...
    }
    
    func get(path: String?) -> DynamicObject {
        .init(stringLiteral: "Dummy")
    }
    
    func clear(path: String?) {
        // Intentionally unimplemented...
    }
}

class OperationsProviderDummy: OperationsProvider {
    func register(operationId: String, handler: @escaping OperationHandler) {
        // Intentionally unimplemented...
    }
    
    func evaluate(with operation: Operation, in view: UIView) -> DynamicObject {
        // Intentionally unimplemented...
        return nil
    }
}
