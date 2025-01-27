//
//  TAButtonView.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 13.01.2025.
//

import SwiftUI

public struct TAAnalyticsButtonView<Label: View>: View {
    public let analyticsName: String
    public let analyticsView: ViewAnalyticsModel
    public let label: Label
    public let action: () -> Void
    public let taAnalytics: TAAnalytics
    
    public init(
        analyticsName: String,
        analyticsView: ViewAnalyticsModel,
        taAnalytics: TAAnalytics,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.analyticsName = analyticsName
        self.analyticsView = analyticsView
        self.label = label()
        self.action = action
        self.taAnalytics = taAnalytics
    }
    
    public var body: some View {
        Button {
            taAnalytics.track(buttonTap: analyticsName, onView: analyticsView)
            action()
        } label: {
            label
        }
    }
}
