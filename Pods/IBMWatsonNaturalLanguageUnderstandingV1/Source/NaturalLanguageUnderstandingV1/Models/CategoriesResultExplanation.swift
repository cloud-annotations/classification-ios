/**
 * Copyright IBM Corporation 2019
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

/**
 Information that helps to explain what contributed to the categories result.
 */
public struct CategoriesResultExplanation: Codable, Equatable {

    /**
     An array of relevant text from the source that contributed to the categorization. The sorted array begins with the
     phrase that contributed most significantly to the result, followed by phrases that were less and less impactful.
     */
    public var relevantText: [CategoriesRelevantText]?

    // Map each property name to the key that shall be used for encoding/decoding.
    private enum CodingKeys: String, CodingKey {
        case relevantText = "relevant_text"
    }

}
