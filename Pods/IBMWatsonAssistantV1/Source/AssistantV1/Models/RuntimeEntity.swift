/**
 * (C) Copyright IBM Corp. 2018, 2019.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import RestKit

/**
 A term from the request that was identified as an entity.
 */
public struct RuntimeEntity: Codable, Equatable {

    /**
     An entity detected in the input.
     */
    public var entity: String

    /**
     An array of zero-based character offsets that indicate where the detected entity values begin and end in the input
     text.
     */
    public var location: [Int]

    /**
     The entity value that was recognized in the user input.
     */
    public var value: String

    /**
     A decimal percentage that represents Watson's confidence in the recognized entity.
     */
    public var confidence: Double?

    /**
     Any metadata for the entity.
     */
    public var metadata: [String: JSON]?

    /**
     The recognized capture groups for the entity, as defined by the entity pattern.
     */
    public var groups: [CaptureGroup]?

    /// Additional properties associated with this model.
    public var additionalProperties: [String: JSON]

    // Map each property name to the key that shall be used for encoding/decoding.
    private enum CodingKeys: String, CodingKey {
        case entity = "entity"
        case location = "location"
        case value = "value"
        case confidence = "confidence"
        case metadata = "metadata"
        case groups = "groups"
        static let allValues = [entity, location, value, confidence, metadata, groups]
    }

    /**
     Initialize a `RuntimeEntity` with member variables.

     - parameter entity: An entity detected in the input.
     - parameter location: An array of zero-based character offsets that indicate where the detected entity values
       begin and end in the input text.
     - parameter value: The entity value that was recognized in the user input.
     - parameter confidence: A decimal percentage that represents Watson's confidence in the recognized entity.
     - parameter metadata: Any metadata for the entity.
     - parameter groups: The recognized capture groups for the entity, as defined by the entity pattern.

     - returns: An initialized `RuntimeEntity`.
     */
    public init(
        entity: String,
        location: [Int],
        value: String,
        confidence: Double? = nil,
        metadata: [String: JSON]? = nil,
        groups: [CaptureGroup]? = nil,
        additionalProperties: [String: JSON] = [:]
    )
    {
        self.entity = entity
        self.location = location
        self.value = value
        self.confidence = confidence
        self.metadata = metadata
        self.groups = groups
        self.additionalProperties = additionalProperties
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        entity = try container.decode(String.self, forKey: .entity)
        location = try container.decode([Int].self, forKey: .location)
        value = try container.decode(String.self, forKey: .value)
        confidence = try container.decodeIfPresent(Double.self, forKey: .confidence)
        metadata = try container.decodeIfPresent([String: JSON].self, forKey: .metadata)
        groups = try container.decodeIfPresent([CaptureGroup].self, forKey: .groups)
        let dynamicContainer = try decoder.container(keyedBy: DynamicKeys.self)
        additionalProperties = try dynamicContainer.decode([String: JSON].self, excluding: CodingKeys.allValues)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(entity, forKey: .entity)
        try container.encode(location, forKey: .location)
        try container.encode(value, forKey: .value)
        try container.encodeIfPresent(confidence, forKey: .confidence)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(groups, forKey: .groups)
        var dynamicContainer = encoder.container(keyedBy: DynamicKeys.self)
        try dynamicContainer.encodeIfPresent(additionalProperties)
    }

}
