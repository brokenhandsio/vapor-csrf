import XCTest
import VaporCSRF
import Vapor
import XCTVapor

final class CSRFTests: XCTestCase {

    var app: Application!

    override func setUpWithError() throws {
        app = Application(.testing)
        app.get("form") { req -> String in
            return "OK"
        }
        app.post("form") { req -> String in
            return "OK"
        }
    }

    func testGettingForm() throws {
        try app.test(.GET, "form", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
        })
    }
}
