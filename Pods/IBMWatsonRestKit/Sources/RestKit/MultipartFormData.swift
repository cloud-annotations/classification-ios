/**
 * Copyright IBM Corporation 2016, 2018
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

public class MultipartFormData {

    public var contentType: String { return "multipart/form-data; boundary=\(boundary)" }
    // add contentLength?

    let boundary: String
    var bodyParts = [BodyPart]()

    // Strings in Swift use Unicode internally, so encoding a string using a Unicode encoding will always succeed.
    // swiftlint:disable force_unwrapping
    private var initialBoundary: Data {
        let boundary = "--\(self.boundary)\r\n"
        return boundary.data(using: .utf8, allowLossyConversion: false)!
    }

    private var encapsulatedBoundary: Data {
        let boundary = "\r\n--\(self.boundary)\r\n"
        return boundary.data(using: .utf8, allowLossyConversion: false)!
    }

    private var finalBoundary: Data {
        let boundary = "\r\n--\(self.boundary)--\r\n"
        return boundary.data(using: .utf8, allowLossyConversion: false)!
    }
    // swiftlint:enable force_unwrapping

    public init() {
        self.boundary = "watson-apis.boundary.bd0b4c6e3b9c2126"
    }

    public func append(_ data: Data, withName: String, mimeType: String? = nil, fileName: String? = nil) {
        let bodyPart = BodyPart(key: withName, data: data, mimeType: mimeType, fileName: fileName)
        bodyParts.append(bodyPart)
    }

    public func append(_ fileURL: URL, withName: String, mimeType: String? = nil) {
        if let data = try? Data(contentsOf: fileURL) {
            let bodyPart = BodyPart(key: withName, data: data, mimeType: mimeType, fileName: fileURL.lastPathComponent)
            bodyParts.append(bodyPart)
        }
    }

    public func append(file fileURL: URL, withName: String, mimeType: String? = nil) throws {
       if let data = try? Data(contentsOf: fileURL) {
            let bodyPart = BodyPart(key: withName, data: data, mimeType: mimeType, fileName: fileURL.lastPathComponent)
            bodyParts.append(bodyPart)
        } else {
            throw RestError.serialization(values: "file contents")
        }
    }

    public func toData() throws -> Data {
        var data = Data()
        for (index, bodyPart) in bodyParts.enumerated() {
            let bodyBoundary: Data
            if index == 0 {
                bodyBoundary = initialBoundary
            } else {
                bodyBoundary = encapsulatedBoundary
            }

            data.append(bodyBoundary)
            data.append(try bodyPart.content())
        }

        data.append(finalBoundary)

        return data
    }
}

internal struct BodyPart {

    private(set) var key: String
    private(set) var data: Data
    private(set) var mimeType: String?
    private(set) var fileName: String?

    internal init?(key: String, value: Any) {
        let string = String(describing: value)
        guard let data = string.data(using: .utf8) else {
            return nil
        }

        self.key = key
        self.data = data
    }

    internal init(key: String, data: Data, mimeType: String? = nil, fileName: String? = nil) {
        self.key = key
        self.data = data
        self.mimeType = mimeType
        self.fileName = fileName
    }

    private var header: String {
        var header = "Content-Disposition: form-data; name=\"\(key)\""
        if let fileName = fileName {
            header += "; filename=\"\(fileName)\""
        }
        if let mimeType = mimeType {
            header += "\r\nContent-Type: \(mimeType)"
        }
        header += "\r\n\r\n"
        return header
    }

    internal func content() throws -> Data {
        var result = Data()
        let headerString = header
        guard let header = headerString.data(using: .utf8) else {
            throw RestError.serialization(values: headerString)
        }
        result.append(header)
        result.append(data)
        return result
    }
}
