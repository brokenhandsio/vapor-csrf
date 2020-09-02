import Vapor

public struct CSRFMiddleware: Middleware {
    public init() {}

    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        if request.method == .POST {
            do {
                try request.csrf.verifyToken()
            } catch {
                return request.eventLoop.makeFailedFuture(error)
            }
        }
        return next.respond(to: request)
    }
}
