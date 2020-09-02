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
            guard let providedToken = try? self.req.content.get(String.self, at: req.application.csrf.tokenContentKey), providedToken == storedToken else {
                throw Abort(.badRequest)
            }
        }
    }

    public var csrf: CSRF {
        return CSRF(req: self)
    }
}

extension Application {
    public struct CSRF {
        let application: Application
        public var tokenContentKey: String {
            self.storage.tokenContentKey
        }

        public func setTokenContentKey(_ newKey: String) {
            self.storage.tokenContentKey = newKey
        }

        final class Storage {
            var tokenContentKey: String
            init() {
                tokenContentKey = "csrfToken"
            }
        }

        struct Key: StorageKey {
            typealias Value = Storage
        }

        var storage: Storage {
            if let storage = self.application.storage[Key.self] {
                return storage
            } else {
                let storage = Storage()
                self.application.storage[Key.self] = storage
                return storage
            }
        }
    }
    public var csrf: CSRF {
        return CSRF(application: self)
    }
}
