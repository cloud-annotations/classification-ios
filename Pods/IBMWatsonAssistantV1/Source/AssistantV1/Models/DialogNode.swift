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

/** DialogNode. */
public struct DialogNode: Codable, Equatable {

    /**
     How the dialog node is processed.
     */
    public enum NodeType: String {
        case standard = "standard"
        case eventHandler = "event_handler"
        case frame = "frame"
        case slot = "slot"
        case responseCondition = "response_condition"
        case folder = "folder"
    }

    /**
     How an `event_handler` node is processed.
     */
    public enum EventName: String {
        case focus = "focus"
        case input = "input"
        case filled = "filled"
        case validate = "validate"
        case filledMultiple = "filled_multiple"
        case generic = "generic"
        case nomatch = "nomatch"
        case nomatchResponsesDepleted = "nomatch_responses_depleted"
        case digressionReturnPrompt = "digression_return_prompt"
    }

    /**
     Whether this top-level dialog node can be digressed into.
     */
    public enum DigressIn: String {
        case notAvailable = "not_available"
        case returns = "returns"
        case doesNotReturn = "does_not_return"
    }

    /**
     Whether this dialog node can be returned to after a digression.
     */
    public enum DigressOut: String {
        case allowReturning = "allow_returning"
        case allowAll = "allow_all"
        case allowAllNeverReturn = "allow_all_never_return"
    }

    /**
     Whether the user can digress to top-level nodes while filling out slots.
     */
    public enum DigressOutSlots: String {
        case notAllowed = "not_allowed"
        case allowReturning = "allow_returning"
        case allowAll = "allow_all"
    }

    /**
     The dialog node ID. This string must conform to the following restrictions:
     - It can contain only Unicode alphanumeric, space, underscore, hyphen, and dot characters.
     */
    public var dialogNode: String

    /**
     The description of the dialog node. This string cannot contain carriage return, newline, or tab characters.
     */
    public var description: String?

    /**
     The condition that will trigger the dialog node. This string cannot contain carriage return, newline, or tab
     characters.
     */
    public var conditions: String?

    /**
     The ID of the parent dialog node. This property is omitted if the dialog node has no parent.
     */
    public var parent: String?

    /**
     The ID of the previous sibling dialog node. This property is omitted if the dialog node has no previous sibling.
     */
    public var previousSibling: String?

    /**
     The output of the dialog node. For more information about how to specify dialog node output, see the
     [documentation](https://cloud.ibm.com/docs/services/assistant?topic=assistant-dialog-overview#dialog-overview-responses).
     */
    public var output: DialogNodeOutput?

    /**
     The context for the dialog node.
     */
    public var context: [String: JSON]?

    /**
     The metadata for the dialog node.
     */
    public var metadata: [String: JSON]?

    /**
     The next step to execute following this dialog node.
     */
    public var nextStep: DialogNodeNextStep?

    /**
     The alias used to identify the dialog node. This string must conform to the following restrictions:
     - It can contain only Unicode alphanumeric, space, underscore, hyphen, and dot characters.
     */
    public var title: String?

    /**
     How the dialog node is processed.
     */
    public var nodeType: String?

    /**
     How an `event_handler` node is processed.
     */
    public var eventName: String?

    /**
     The location in the dialog context where output is stored.
     */
    public var variable: String?

    /**
     An array of objects describing any actions to be invoked by the dialog node.
     */
    public var actions: [DialogNodeAction]?

    /**
     Whether this top-level dialog node can be digressed into.
     */
    public var digressIn: String?

    /**
     Whether this dialog node can be returned to after a digression.
     */
    public var digressOut: String?

    /**
     Whether the user can digress to top-level nodes while filling out slots.
     */
    public var digressOutSlots: String?

    /**
     A label that can be displayed externally to describe the purpose of the node to users.
     */
    public var userLabel: String?

    /**
     For internal use only.
     */
    public var disabled: Bool?

    /**
     The timestamp for creation of the object.
     */
    public var created: Date?

    /**
     The timestamp for the most recent update to the object.
     */
    public var updated: Date?

    // Map each property name to the key that shall be used for encoding/decoding.
    private enum CodingKeys: String, CodingKey {
        case dialogNode = "dialog_node"
        case description = "description"
        case conditions = "conditions"
        case parent = "parent"
        case previousSibling = "previous_sibling"
        case output = "output"
        case context = "context"
        case metadata = "metadata"
        case nextStep = "next_step"
        case title = "title"
        case nodeType = "type"
        case eventName = "event_name"
        case variable = "variable"
        case actions = "actions"
        case digressIn = "digress_in"
        case digressOut = "digress_out"
        case digressOutSlots = "digress_out_slots"
        case userLabel = "user_label"
        case disabled = "disabled"
        case created = "created"
        case updated = "updated"
    }

    /**
     Initialize a `DialogNode` with member variables.

     - parameter dialogNode: The dialog node ID. This string must conform to the following restrictions:
       - It can contain only Unicode alphanumeric, space, underscore, hyphen, and dot characters.
     - parameter description: The description of the dialog node. This string cannot contain carriage return,
       newline, or tab characters.
     - parameter conditions: The condition that will trigger the dialog node. This string cannot contain carriage
       return, newline, or tab characters.
     - parameter parent: The ID of the parent dialog node. This property is omitted if the dialog node has no parent.
     - parameter previousSibling: The ID of the previous sibling dialog node. This property is omitted if the dialog
       node has no previous sibling.
     - parameter output: The output of the dialog node. For more information about how to specify dialog node output,
       see the
       [documentation](https://cloud.ibm.com/docs/services/assistant?topic=assistant-dialog-overview#dialog-overview-responses).
     - parameter context: The context for the dialog node.
     - parameter metadata: The metadata for the dialog node.
     - parameter nextStep: The next step to execute following this dialog node.
     - parameter title: The alias used to identify the dialog node. This string must conform to the following
       restrictions:
       - It can contain only Unicode alphanumeric, space, underscore, hyphen, and dot characters.
     - parameter nodeType: How the dialog node is processed.
     - parameter eventName: How an `event_handler` node is processed.
     - parameter variable: The location in the dialog context where output is stored.
     - parameter actions: An array of objects describing any actions to be invoked by the dialog node.
     - parameter digressIn: Whether this top-level dialog node can be digressed into.
     - parameter digressOut: Whether this dialog node can be returned to after a digression.
     - parameter digressOutSlots: Whether the user can digress to top-level nodes while filling out slots.
     - parameter userLabel: A label that can be displayed externally to describe the purpose of the node to users.
     - parameter disabled: For internal use only.
     - parameter created: The timestamp for creation of the object.
     - parameter updated: The timestamp for the most recent update to the object.

     - returns: An initialized `DialogNode`.
     */
    public init(
        dialogNode: String,
        description: String? = nil,
        conditions: String? = nil,
        parent: String? = nil,
        previousSibling: String? = nil,
        output: DialogNodeOutput? = nil,
        context: [String: JSON]? = nil,
        metadata: [String: JSON]? = nil,
        nextStep: DialogNodeNextStep? = nil,
        title: String? = nil,
        nodeType: String? = nil,
        eventName: String? = nil,
        variable: String? = nil,
        actions: [DialogNodeAction]? = nil,
        digressIn: String? = nil,
        digressOut: String? = nil,
        digressOutSlots: String? = nil,
        userLabel: String? = nil,
        disabled: Bool? = nil,
        created: Date? = nil,
        updated: Date? = nil
    )
    {
        self.dialogNode = dialogNode
        self.description = description
        self.conditions = conditions
        self.parent = parent
        self.previousSibling = previousSibling
        self.output = output
        self.context = context
        self.metadata = metadata
        self.nextStep = nextStep
        self.title = title
        self.nodeType = nodeType
        self.eventName = eventName
        self.variable = variable
        self.actions = actions
        self.digressIn = digressIn
        self.digressOut = digressOut
        self.digressOutSlots = digressOutSlots
        self.userLabel = userLabel
        self.disabled = disabled
        self.created = created
        self.updated = updated
    }

}
