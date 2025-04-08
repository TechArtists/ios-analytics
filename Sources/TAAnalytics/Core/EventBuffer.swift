//
//  EventBuffer.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 23.09.2024.
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
import OSLog

public struct DeferredQueuedEvent {
    let event: EventAnalyticsModel
    let dateAdded: Date
    let parameters: [String: (any AnalyticsBaseParameterValue)]?
}

struct Queue<T> {
    private var array = [T?]()
    private var head = 0
  
    public var isEmpty: Bool {
        return count == 0
    }
    
    public var count: Int {
        return array.count - head
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        guard head < array.count, let element = array[head] else { return nil }
        
        array[head] = nil
        head += 1
        
        let percentage = Double(head)/Double(array.count)
        if array.count > 50 && percentage > 0.25 {
            array.removeFirst(head)
            head = 0
        }
        
        return element
    }
    
    public var front: T? {
        if isEmpty {
            return nil
        } else {
            return array[head]
        }
    }
}

actor EventBuffer {
    private var eventQueue: Queue<DeferredQueuedEvent> = .init()
    
    nonisolated(unsafe) private(set) var startedAdaptors: [any AnalyticsAdaptor] = []
    
    public let allAdaptors: [any AnalyticsAdaptor]
    
    nonisolated(unsafe) internal let passthroughStream = PassthroughAsyncStream<DeferredQueuedEvent>()
    
    init(allAdaptors: [any AnalyticsAdaptor]) {
        self.allAdaptors = allAdaptors
    }
    
    func addEvent(
        _ event: EventAnalyticsModel,
        params: [String: (any AnalyticsBaseParameterValue)]? = nil
    ) {
        if startedAdaptors.isEmpty {
            eventQueue.enqueue(.init(event: event, dateAdded: Date(), parameters: params))
        } else {
            trackEventInStartedAdaptors(event, params: params)
        }
    }
    
    func setupAdaptors(with adaptors: [any AnalyticsAdaptor]) {
        self.startedAdaptors = adaptors
        flushDeferredEventQueue()
    }
    
    private func trackEventInStartedAdaptors(
        _ event: EventAnalyticsModel,
        params: [String: (any AnalyticsBaseParameterValue)]? = nil
    ) {
        for adaptor in startedAdaptors {
            adaptor.track(trimmedEvent: adaptor.trim(event: event), params: params)
            TALogger.log("Adaptor: '\(String(describing: adaptor))' has logged event: '\(adaptor.trim(event: event).rawValue)'", level: .info)
        }
        passthroughStream.send(.init(event: event, dateAdded: Date(), parameters: params))
    }
    
    private func flushDeferredEventQueue() {
        while let deferredEvent = eventQueue.dequeue() {
            let event = deferredEvent.event
            var params = deferredEvent.parameters ?? [:]
            params["timeDelta"] = Date().timeIntervalSince(deferredEvent.dateAdded)
            trackEventInStartedAdaptors(event, params: params)
        }
    }
}
