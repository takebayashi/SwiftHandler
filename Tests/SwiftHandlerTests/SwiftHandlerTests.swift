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

import XCTest
import SwiftServerHttp
@testable import SwiftHandler

class SwiftHandlerTests: XCTestCase {
    func testSimpleHandler() {
        let server = BlueSocketSimpleServer()
        let handler = SimpleHandler { request, data in
            let response = HTTPResponse(
                httpVersion: request.httpVersion,
                status: .ok,
                transferEncoding: .identity(contentLength: UInt(data.count)),
                headers: HTTPHeaders([])
            )
            return (response, data)
        }
        do {
            try server.start(port: 0, webapp: handler)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let expectation = self.expectation(description: "Handler should echo")
            var req = URLRequest(url: URL(string: "http://localhost:\(server.port)/")!)
            req.httpMethod = "POST"
            req.httpBody = "Hello, world!".data(using: .utf8)
            let task = session.dataTask(with: req) { (responseBody, rawResponse, error) in
                let response = rawResponse as? HTTPURLResponse
                XCTAssertNil(error, "\(error!.localizedDescription)")
                XCTAssertNotNil(response)
                XCTAssertNotNil(responseBody)
                XCTAssertEqual(Int(HTTPResponseStatus.ok.code), response?.statusCode ?? 0)
                XCTAssertEqual("Hello, world!", String(data: responseBody ?? Data(), encoding: .utf8) ?? "")
                expectation.fulfill()
            }
            task.resume()
            self.waitForExpectations(timeout: 10) { (error) in
                if let error = error {
                    XCTFail("\(error)")
                }
            }
            server.stop()
        } catch {
            XCTFail("\(error) (port \(0))")
        }
    }


    static var allTests = [
        ("testSimpleHandler", testSimpleHandler),
    ]
}
