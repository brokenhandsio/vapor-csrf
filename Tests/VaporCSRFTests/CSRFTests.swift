import XCTest
import VaporCSRF
import Vapor
import XCTVapor

final class CSRFTests: XCTestCase {

    var app: Application!
    var viewRenderer: CapturingViewRenderer!
    var eventLoopGroup: EventLoopGroup!

    override func setUpWithError() throws {
        eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        viewRenderer = CapturingViewRenderer(eventLoop: eventLoopGroup.next())
        app = Application(.testing, .shared(eventLoopGroup))
        app.views.use { _ in
            self.viewRenderer
        }
        app.get("form") { req -> EventLoopFuture<View> in
            let context = ViewContext(csrfToken: "sometoken")
            return req.view.render("page", context)
        }
        app.post("form") { req -> String in
            return "OK"
        }
    }

    override func tearDownWithError() throws {
        self.app.shutdown()
        try self.eventLoopGroup.syncShutdownGracefully()
    }

    func testGettingFormProvidesAUniqueToken() throws {
        try app.test(.GET, "form", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let context1 = try XCTUnwrap(viewRenderer.capturedContext as? ViewContext)
            try app.test(.GET, "form", afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
                let context2 = try XCTUnwrap(viewRenderer.capturedContext as? ViewContext)
                XCTAssertNotEqual(context1.csrfToken, context2.csrfToken)
            })
        })
    }

    func testAccessingPostPageWithoutTokenReturnsError() throws {
        try app.test(.POST, "form", afterResponse: { res in
            XCTAssertEqual(res.status, .badRequest)
        })
    }

    func testAccessingPostPageWorksWithToken() throws {
        try app.test(.GET, "form", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let context = try XCTUnwrap(viewRenderer.capturedContext as? ViewContext)
            try app.test(.POST, "form", beforeRequest: { postRequest in
                let content = FormData(csrfToken: context.csrfToken)
                try postRequest.content.encode(content)
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
            })
        })
    }
}
