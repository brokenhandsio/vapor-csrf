import Vapor

struct FormData: Content {
    static let defaultContentType: HTTPMediaType = .urlEncodedForm
    let csrfToken: String
}
