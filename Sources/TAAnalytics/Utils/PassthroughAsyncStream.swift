//
//  PassthroughAsyncStream.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 30.10.2024.
//

import Foundation

/// A class that simulates Combine's PassthroughSubject using AsyncStream
class PassthroughAsyncStream<T> {
    private var continuation: AsyncStream<T>.Continuation?
    
    /// The async stream to which subscribers can listen
    lazy var stream: AsyncStream<T> = {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }()
    
    /// Sends a new value to the subscribers
    func send(_ value: T) {
        continuation?.yield(value)
    }
    
    /// Completes the stream, notifying all subscribers of completion
    func sendCompletion() {
        continuation?.finish()
    }
}
