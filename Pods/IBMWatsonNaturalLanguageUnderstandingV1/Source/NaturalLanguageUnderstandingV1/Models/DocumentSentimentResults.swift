/**
 * (C) Copyright IBM Corp. 2017, 2018.
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

/** DocumentSentimentResults. */
public struct DocumentSentimentResults: Codable, Equatable {

    /**
     Indicates whether the sentiment is positive, neutral, or negative.
     */
    public var label: String?

    /**
     Sentiment score from -1 (negative) to 1 (positive).
     */
    public var score: Double?

    // Map each property name to the key that shall be used for encoding/decoding.
    private enum CodingKeys: String, CodingKey {
        case label = "label"
        case score = "score"
    }

}
