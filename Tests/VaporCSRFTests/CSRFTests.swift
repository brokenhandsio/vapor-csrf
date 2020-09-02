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
        app.middleware.use(app.sessions.middleware)
        app.views.use { _ in
            self.viewRenderer
        }
        app.get("form") { req -> EventLoopFuture<View> in
            let token = req.csrf.storeToken()
            let context = ViewContext(csrfToken: token)
            return req.view.render("page", context)
        }
        app.post("form") { req -> String in
            return "OK"
        }
        app.post("manualForm") { req -> String in
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

    func testAccessingPostPageUsingCustomCSRFKey() throws {
        struct DifferentFormData: Content {
            static let defaultContentType: HTTPMediaType = .urlEncodedForm
            let aTokenForCSRF: String
        }

        try app.test(.GET, "form", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let context = try XCTUnwrap(viewRenderer.capturedContext as? ViewContext)
            try app.test(.POST, "form", beforeRequest: { postRequest in
                let content = DifferentFormData(aTokenForCSRF: context.csrfToken)
                try postRequest.content.encode(content)
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
            })
        })
    }

    func testManualVerifyOfCSRFToken() throws {
        try app.test(.GET, "form", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let context = try XCTUnwrap(viewRenderer.capturedContext as? ViewContext)
            try app.test(.POST, "manualForm", beforeRequest: { postRequest in
                let content = FormData(csrfToken: context.csrfToken)
                try postRequest.content.encode(content)
            }, afterResponse: { res in
                XCTAssertEqual(res.status, .ok)
            })
        })
    }
}
