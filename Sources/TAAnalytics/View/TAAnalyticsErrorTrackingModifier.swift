//
//  TAAnalyticsErrorTrackingModifier.swift
//  TAAnalytics
//

import SwiftUI

private struct TAAnalyticsErrorTrackingModifier: ViewModifier {
    @EnvironmentObject private var taAnalytics: TAAnalytics

    let isPresented: Bool
    let reason: String
    let extraParams: [String: any AnalyticsBaseParameterValue]?

    func body(content: Content) -> some View {
        content.onChange(of: isPresented) { isPresented in
            guard isPresented else { return }
            taAnalytics.trackErrorEvent(reason: reason, extraParams: extraParams)
        }
    }
}

public extension View {
    /// Tracks an analytics error whenever `isPresented` changes from `false` to `true`.
    ///
    /// This is intended for SwiftUI alerts and other error UI driven by a Boolean binding.
    /// An initially `true` value is not tracked because no presentation transition occurred.
    func trackAnalyticsError(
        isPresented: Bool,
        reason: String,
        extraParams: [String: any AnalyticsBaseParameterValue]? = nil
    ) -> some View {
        modifier(TAAnalyticsErrorTrackingModifier(isPresented: isPresented, reason: reason, extraParams: extraParams))
    }
}
