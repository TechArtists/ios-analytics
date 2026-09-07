//
//  BufferedAsyncStream.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 30.10.2024.
//  Copyright (c) 2022 Tech Artists Agency SRL
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

/// A single-consumer `AsyncStream` with an unbounded buffer, written to through
/// ``send(_:)``.
///
/// This is deliberately **not** a Combine `PassthroughSubject`: a subject drops a
/// value that arrives while nothing is subscribed, whereas this type queues every
/// value until an iterator consumes it. That is the point — values sent before
/// iteration begins are still delivered — but it also means an instance nothing
/// iterates retains every value it was sent, for as long as the instance lives.
///
/// So create one only where something will actually read it, and keep it out of
/// paths that run in normal app usage.
class BufferedAsyncStream<T> {
    private var continuation: AsyncStream<T>.Continuation?

    /// The stream to iterate. Values sent before iteration starts are buffered
    /// rather than dropped.
    let stream: AsyncStream<T>

    init() {
        var capturedContinuation: AsyncStream<T>.Continuation?
        stream = AsyncStream { continuation in
            capturedContinuation = continuation
        }
        continuation = capturedContinuation
    }

    /// Queues a value for the consumer, delivering it immediately if one is
    /// already waiting in `next()`.
    func send(_ value: T) {
        continuation?.yield(value)
    }

    /// Ends the stream, finishing the consumer's iteration once it has drained
    /// whatever is still buffered.
    func sendCompletion() {
        continuation?.finish()
    }
}
