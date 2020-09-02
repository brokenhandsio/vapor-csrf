import Vapor

class CapturingViewRenderer: ViewRenderer {

    let eventLoop: EventLoop

    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }

    private(set) var capturedContext: Encodable?
    func render<E>(_ name: String, _ context: E) -> EventLoopFuture<View> where E : Encodable {
        self.capturedContext = context
        let response = "Test"
        var byteBuffer = ByteBufferAllocator().buffer(capacity: response.count)
        byteBuffer.writeString(response)
        return self.eventLoop.future(View(data: byteBuffer))
    }

    func `for`(_ request: Request) -> ViewRenderer {
        return self
    }
}
