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

class ActionRecordFactoryTests: RecordFactoryHelpers {

    // MARK: Default Record

    func testRecordWithAllDefaultProperties() throws {
        // Given
        actionWithConfig(.enabled(nil))
        // And
        try prepareComponentHierarchy()

        // When
        var record = sut.makeRecord()
        record?.timestamp = 0 // setting to avoid getting a different timestamp between runs

        // Then should have all default properties
        _assertInlineSnapshot(matching: record, as: .json, with: """
        {
          "beagleAction" : "beagle:sendrequest",
          "component" : {
            "id" : "test-component-id",
            "position" : {
              "x" : 0,
              "y" : 0
            },
            "type" : "custom:analyticstestcomponent"
          },
          "event" : "event",
          "platform" : "ios",
          "screen" : "analytics-actions",
          "timestamp" : 0,
          "type" : "action"
        }
        """)
    }

    // MARK: Only Global Config

    func testJustGlobalConfig() {
        // Given
        globalConfigWithActionEnabled()
        // And
        actionWithConfig(nil)

        // Then should obey global config
        recordShouldBeEqualTo("""
        {
          "attributes" : {
            "method" : "DELETE",
            "url" : "PATH"
          }
        }
        """)
    }

    func testJustUsingGlobalConfigEmpty() {
        // Given
        emptyGlobalConfig()
        // And
        actionWithConfig(nil)

        // Then should obey global config
        recordShouldBeEqualTo("""
        null
        """)
    }

    // MARK: Action precedence

    func testEnabledActionWith1Attribute() {
        // Given
        emptyGlobalConfig()
        // And
        actionWithJust1AttributeEnabled()

        // Then should create a record with just 1 attribute
        recordShouldBeEqualTo("""
        {
          "attributes" : {
            "method" : "DELETE"
          }
        }
        """)
    }
    
    func testDisabledActionShouldOverrideGlobalConfig() {
        // Given
        globalConfigWithActionEnabled()
        // And
        actionWithConfig(.disabled)

        // Then should NOT create record
        recordShouldBeEqualTo("""
        null
        """)
    }

    func testActionWithEnabledNilAndGlobalConfigEnabled() {
        // Given
        globalConfigWithActionEnabled()
        // And
        actionWithConfig(.enabled(nil))

        // Then should use global config
        recordShouldBeEqualTo("""
        {
          "attributes" : {
            "method" : "DELETE",
            "url" : "PATH"
          }
        }
        """)
    }

    func testActionWithEnabledAttributesAndGlobalConfigEnabled() {
        // Given
        globalConfigWithActionEnabled()
        // And
        actionWithJust1AttributeEnabled()

        // Then should use Action config
        recordShouldBeEqualTo("""
        {
          "attributes" : {
            "method" : "DELETE"
          }
        }
        """)
    }

    // MARK: Additional Entries

    func testAdditionalEntries() {
        // Given
        actionWithConfig(.enabled(.init(
            additionalEntries: ["additional": "NEW ENTRY"]
        )))

        // Then
        recordShouldBeEqualTo("""
        {
          "additionalEntries" : {
            "additional" : "NEW ENTRY"
          }
        }
        """)
    }

    func testAdditionalEntriesAndAttributes() {
        // Given
        actionWithConfig(.enabled(.init(
            attributes: ["url"],
            additionalEntries: ["additional": "NEW ENTRY"]
        )))

        // Then
        recordShouldBeEqualTo("""
        {
          "additionalEntries" : {
            "additional" : "NEW ENTRY"
          },
          "attributes" : {
            "url" : "PATH"
          }
        }
        """)
    }
}

// MARK: - Aux

class RecordFactoryHelpers: XCTestCase {

    lazy var sut = ActionRecordFactory(info: info, globalConfig: _globalConfig.actions)

    // swiftlint:disable implicitly_unwrapped_optional
    var action: SendRequest!

    lazy var info = AnalyticsService.ActionInfo(
        action: action,
        event: "event",
        origin: ViewDummy(),
        controller: BeagleScreenViewController(ComponentDummy())
    )

    lazy var _globalConfig = AnalyticsConfig()

    func actionWithConfig(_ config: ActionAnalyticsConfig?) {
        action = SendRequest(
            url: "PATH",
            method: .value(.delete),
            analytics: config
        )
    }

    func actionWithJust1AttributeEnabled() {
        actionWithConfig(.enabled(.init(attributes: ["method"])))
    }

    func emptyGlobalConfig() {
        _globalConfig =  .init(actions: [:])
    }

    func globalConfigWithActionEnabled() {
        _globalConfig = .init(actions: [
            "beagle:sendrequest": ["method", "url"]
        ])
    }

    func recordShouldBeEqualTo(
        _ string: String,
        record: Bool = false,
        testName: String = #function,
        line: UInt = #line
    ) {
        // When
        let result = sut.makeRecord()
            .ifSome { $0.onlyAttributesAndAdditional() }

        // Then
        _assertInlineSnapshot(matching: result, as: .json, record: record, with: string, testName: testName, line: line)
    }

    func prepareComponentHierarchy() throws {
        let (view, controller) = try analyticsViewHierarchyWith(context: nil)
        info = .init(action: action, event: "event", origin: view, controller: controller)
    }
}

extension AnalyticsRecord {
    func onlyAttributesAndAdditional() -> DynamicDictionary {
        var dict = toDictionary()
        dict = dict.getSomeAttributes(["attributes", "additionalEntries"], contextProvider: nil)
        return dict
    }
}
