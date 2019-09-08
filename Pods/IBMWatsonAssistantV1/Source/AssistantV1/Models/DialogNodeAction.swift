/**
 * (C) Copyright IBM Corp. 2017, 2019.
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

/** DialogNodeAction. */
public struct DialogNodeAction: Codable, Equatable {

    /**
     The type of action to invoke.
     */
    public enum ActionType: String {
        case client = "client"
        case server = "server"
        case cloudFunction = "cloud_function"
        case webAction = "web_action"
    }

    /**
     The name of the action.
     */
    public var name: String

    /**
     The type of action to invoke.
     */
    public var actionType: String?

    /**
     A map of key/value pairs to be provided to the action.
     */
    public var parameters: [String: JSON]?

    /**
     The location in the dialog context where the result of the action is stored.
     */
    public var resultVariable: String

    /**
     The name of the context variable that the client application will use to pass in credentials for the action.
     */
    public var credentials: String?

    // Map each property name to the key that shall be used for encoding/decoding.
    private enum CodingKeys: String, CodingKey {
        case name = "name"
        case actionType = "type"
        case parameters = "parameters"
        case resultVariable = "result_variable"
        case credentials = "credentials"
    }

    /**
     Initialize a `DialogNodeAction` with member variables.

     - parameter name: The name of the action.
     - parameter resultVariable: The location in the dialog context where the result of the action is stored.
     - parameter actionType: The type of action to invoke.
     - parameter parameters: A map of key/value pairs to be provided to the action.
     - parameter credentials: The name of the context variable that the client application will use to pass in
       credentials for the action.

     - returns: An initialized `DialogNodeAction`.
     */
    public init(
        name: String,
        resultVariable: String,
        actionType: String? = nil,
        parameters: [String: JSON]? = nil,
        credentials: String? = nil
    )
    {
        self.name = name
        self.resultVariable = resultVariable
        self.actionType = actionType
        self.parameters = parameters
        self.credentials = credentials
    }

}
