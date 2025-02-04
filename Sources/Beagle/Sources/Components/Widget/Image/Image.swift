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

/// Defines an `ImageView` using the server driven information received through Beagle.
public struct Image: Widget {

    /// Defines where the source of the image is.
    public let path: Expression<ImagePath>
    
    /// Defines how the declared image will fit the view.
    public var mode: ImageContentMode?
    
    public var id: String?
    public var style: Style?
    public var accessibility: Accessibility?
    
    public enum ImagePath: Decodable {
        case remote(Remote)
        case local(StringOrExpression)

        enum CodingKeys: String, CodingKey {
            case type = "_beagleImagePath_"
            case mobileId
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let type = try container.decode(String.self, forKey: .type)
            switch type {
            case "local":
                let mobileId = try container.decode(String.self, forKey: .mobileId)
                self = .local(mobileId)
            case "remote":
                self = .remote(try Remote(from: decoder))
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid image type")
            }
        }
    }
}

extension Image {
    init(
        _ path: ImagePath,
        mode: ImageContentMode? = nil,
        id: String? = nil,
        style: Style? = nil,
        accessibility: Accessibility? = nil
    ) {
        self.path = .value(path)
        self.mode = mode
        self.id = id
        self.style = style
        self.accessibility = accessibility
    }
}

public extension Image {
    struct Remote: Decodable {
        public let url: StringOrExpression
        public let placeholder: String?

        public init(url: StringOrExpression, placeholder: String? = nil) {
            self.url = url
            self.placeholder = placeholder
        }

        enum CodingKeys: String, CodingKey {
            case url
            case placeholder
        }
        
        enum LocalImageCodingKey: String, CodingKey {
            case mobileId
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let nestedContainer = try? container.nestedContainer(keyedBy: LocalImageCodingKey.self, forKey: .placeholder)
            url = try container.decode(String.self, forKey: .url)
            placeholder = try nestedContainer?.decodeIfPresent(String.self, forKey: .mobileId)
        }
    }
}
