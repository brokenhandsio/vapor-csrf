import Vapor

extension Request {

    public struct CSRF {
        let req: Request
        private let csrfSessionKey = "__VaporCSRFSessionKey"

        public func storeToken() -> String {
            let csrfToken = [UInt8].random(count: 32).base64
            self.req.session.data[csrfSessionKey] = csrfToken
            return csrfToken
        }

        public func verifyToken() throws {
            guard let storedToken = self.req.session.data[csrfSessionKey] else {
                throw Abort(.badRequest)
            }
            self.req.session.data[csrfSessionKey] = nil
            guard let providedToken = try? self.req.content.get(String.self, at: "csrfToken"), providedToken == storedToken else {
                throw Abort(.badRequest)
            }
        }
    }

    public var csrf: CSRF {
        return CSRF(req: self)
    }
}
