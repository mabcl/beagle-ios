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

/// A text widget will define a text view natively using the server driven information received through Beagle.
public struct Text: Widget {
    
    /// Defines the text view content.
    public let text: Expression<String>
    
    /// References a style configured to be applied on this text view.
    public var styleId: String?
    
    /// Defines the text content alignment inside the text view.
    public var alignment: Expression<Alignment>?
    
    /// Defines the text color natively.
    public var textColor: Expression<String>?
    
    public var id: String?
    public var style: Style?
    public var accessibility: Accessibility?

}

extension Text {
    public enum Alignment: String, Decodable, CaseIterable {
        case left = "LEFT"
        case right = "RIGHT"
        case center = "CENTER"
    }
}
