//
//  EventBuffer.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 23.09.2024.
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
    
    nonisolated(unsafe) private(set) var startedConsumers: [any AnalyticsConsumer] = []
    
    public let allConsumers: [any AnalyticsConsumer]
    
    nonisolated(unsafe) internal let passthroughStream = PassthroughAsyncStream<DeferredQueuedEvent>()
    
    init(allConsumers: [any AnalyticsConsumer]) {
        self.allConsumers = allConsumers
    }
    
    func addEvent(
        _ event: EventAnalyticsModel,
        params: [String: (any AnalyticsBaseParameterValue)]? = nil
    ) {
        if startedConsumers.isEmpty {
            eventQueue.enqueue(.init(event: event, dateAdded: Date(), parameters: params))
        } else {
            trackEventInStartedConsumers(event, params: params)
        }
    }
    
    func setupConsumers(with consumers: [any AnalyticsConsumer]) {
        self.startedConsumers = consumers
        flushDeferredEventQueue()
    }
    
    private func trackEventInStartedConsumers(
        _ event: EventAnalyticsModel,
        params: [String: (any AnalyticsBaseParameterValue)]? = nil
    ) {
        for consumer in startedConsumers {
            consumer.track(trimmedEvent: consumer.trim(event: event), params: params)
            TALogger.log("Consumer: '\(String(describing: consumer))' has logged event: '\(consumer.trim(event: event).rawValue)'", level: .info)
        }
        passthroughStream.send(.init(event: event, dateAdded: Date(), parameters: params))
    }
    
    private func flushDeferredEventQueue() {
        while let deferredEvent = eventQueue.dequeue() {
            let event = deferredEvent.event
            var params = deferredEvent.parameters ?? [:]
            params["timeDelta"] = Date().timeIntervalSince(deferredEvent.dateAdded)
            trackEventInStartedConsumers(event, params: params)
        }
    }
}
