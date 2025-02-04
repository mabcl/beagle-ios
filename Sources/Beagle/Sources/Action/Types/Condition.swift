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

/// Action to resolve condition and call onTrue if return true and onFalse if return is false.
public struct Condition: Action, AutoDecodable {
    
    /// Condition should represents a boolean.
    public var condition: Expression<Bool>
    
    /// Defines the actions triggered if the condition returns true.
    public var onTrue: [Action]?
    
    /// Defines the actions triggered if the condition returns false.
    public var onFalse: [Action]?
    
    /// Defines an analytics configuration for this action.
    public var analytics: ActionAnalyticsConfig?

}
