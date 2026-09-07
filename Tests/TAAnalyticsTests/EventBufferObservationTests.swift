import Foundation
import Testing
@testable import TAAnalytics

struct EventBufferObservationTests {
    @Test(arguments: [false, true])
    func deliveryReleasesParametersWithoutObservation(queueBeforeStartup: Bool) async throws {
        let adaptor = TAAnalyticsUnitTestAdaptor()
        let buffer = EventBuffer(allAdaptors: [adaptor])
        defer { withExtendedLifetime(buffer) {} }

        if !queueBeforeStartup {
            await buffer.setupAdaptors(with: [adaptor])
        }

        weak var retainedPayload: LifetimeProbe?
        var payload: LifetimeProbe? = LifetimeProbe()
        retainedPayload = payload
        await buffer.addEvent(EventAnalyticsModel("lifetime_probe"), params: ["payload": try #require(payload)])
        payload = nil

        if queueBeforeStartup {
            #expect(adaptor.eventsSent.isEmpty)
            #expect(retainedPayload != nil, "The delivery queue must retain unsent parameters")
            await buffer.setupAdaptors(with: [adaptor])
        }

        #expect(adaptor.eventsSent.count == 1)
        #expect(adaptor.eventsSent.first?.event.rawValue == "lifetime_probe")
        #expect(adaptor.eventsSent.first?.params["payload"] as? LifetimeProbe === retainedPayload)

        // The adaptor intentionally records payloads. Once it releases its copy,
        // EventBuffer must not retain another copy after successful delivery.
        adaptor.eventsSent.removeAll()
        #expect(retainedPayload == nil)
    }

    @Test
    func observationCapturesStartupAndLiveEventsBeforeIteration() async throws {
        let adaptor = TAAnalyticsUnitTestAdaptor()
        let buffer = EventBuffer(allAdaptors: [adaptor])
        let events = await buffer.enableEventObservation()

        await buffer.addEvent(EventAnalyticsModel("startup"), params: ["phase": "startup"])
        await buffer.setupAdaptors(with: [adaptor])
        await buffer.addEvent(EventAnalyticsModel("live"), params: ["phase": "live"])

        let observed = try await firstEvents(2, from: events)
        #expect(observed.map { $0.event.rawValue } == ["startup", "live"])
        #expect(observed[0].parameters?["phase"] as? String == "startup")
        #expect(observed[1].parameters?["phase"] as? String == "live")
        #expect(adaptor.eventsSent.map { $0.event.rawValue } == ["startup", "live"])
    }

    @Test
    func enablingObservationAgainPreservesBufferedEvents() async throws {
        let adaptor = TAAnalyticsUnitTestAdaptor()
        let buffer = EventBuffer(allAdaptors: [adaptor])
        await buffer.setupAdaptors(with: [adaptor])
        _ = await buffer.enableEventObservation()
        await buffer.addEvent(EventAnalyticsModel("before_second_enable"))

        let events = await buffer.enableEventObservation()
        await buffer.addEvent(EventAnalyticsModel("after_second_enable"))

        let observed = try await firstEvents(2, from: events)
        #expect(observed.map { $0.event.rawValue } == ["before_second_enable", "after_second_enable"])
    }

    private func firstEvents(
        _ count: Int,
        from stream: AsyncStream<DeferredQueuedEvent>
    ) async throws -> [DeferredQueuedEvent] {
        try await withThrowingTimeout(seconds: 3) {
            var events: [DeferredQueuedEvent] = []
            for await event in stream {
                events.append(event)
                if events.count == count {
                    return events
                }
            }
            throw EventStreamError.eventNotFound
        }
    }
}

private final class LifetimeProbe: AnalyticsBaseParameterValue {
    var description: String { "lifetime probe" }

    static func == (lhs: LifetimeProbe, rhs: LifetimeProbe) -> Bool {
        lhs === rhs
    }
}
