//
//  EventBuffer.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 23.09.2024.
//

import Foundation
import OSLog

public struct DeferedQueuedEvent {
    let event: AnalyticsEvent
    let dateAdded: Date
    let parameters: [String: AnalyticsBaseParameterValue]?
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
    private var eventQueue: Queue<DeferedQueuedEvent> = .init()
    nonisolated(unsafe) private(set) var startedConsumers: [any AnalyticsConsumer] = []
    public let allConsumers: [any AnalyticsConsumer]
    
    init(allConsumers: [any AnalyticsConsumer]) {
        self.allConsumers = allConsumers
    }
    
    func addEvent(
        _ event: AnalyticsEvent,
        params: [String: AnalyticsBaseParameterValue]? = nil
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
        _ event: AnalyticsEvent,
        params: [String: AnalyticsBaseParameterValue]? = nil
    ) {
        for consumer in startedConsumers {
            consumer.track(trimmedEvent: consumer.trim(event: event), params: params)
            os_log(
                "Consumer: '%{public}@' has logged event: '%{public}@'",
                log: LOGGER,
                type: .info,
                String(describing: consumer),
                event.rawValue
            )
        }
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
