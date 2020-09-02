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
    }

    public var csrf: CSRF {
        return CSRF(req: self)
    }
}
