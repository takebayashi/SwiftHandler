/*
 Copyright 2017 Shun Takebayashi.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import HTTP

public typealias Handler = (HTTPRequest, Data) -> (HTTPResponse, Data)

public func SimpleHandler(handler: @escaping Handler) -> HTTPRequestHandler {
    return { (request: HTTPRequest, responseWriter: HTTPResponseWriter) -> HTTPBodyProcessing in
        var received = Data()
        return .processBody { (chunk, stop) in
            switch chunk {
            case .chunk(let data, let finishedProcessing):
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count)
                data.copyBytes(to: buffer, count: data.count)
                received.append(buffer, count: data.count)
                finishedProcessing()
                buffer.deallocate(capacity: data.count)
            case .end:
                let (response, body) = handler(request, received)
                responseWriter.writeHeader(status: response.status, headers: response.headers)
                responseWriter.writeBody(body) { _ in
                    responseWriter.done()
                }
            default:
                stop = true
                responseWriter.abort()
            }
        }
    }
}
