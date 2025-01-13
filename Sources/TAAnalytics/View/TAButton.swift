//
//  TAButton.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 13.01.2025.
//

import SwiftUI

public struct TAButton<Label: View>: View {
    public let buttonName: String
    public let analyticsView: AnalyticsView
    public let label: Label
    public let action: () -> Void
    public let taAnalytics: TAAnalytics
    
    public init(
        buttonName: String,
        analyticsView: AnalyticsView,
        taAnalytics: TAAnalytics,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.buttonName = buttonName
        self.analyticsView = analyticsView
        self.label = label()
        self.action = action
        self.taAnalytics = taAnalytics
    }
    
    public var body: some View {
        Button {
            taAnalytics.track(buttonTapped: buttonName, onView: analyticsView)
            action()
        } label: {
            label
        }
    }
}
