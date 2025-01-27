//
//  TAView.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 13.01.2025.
//

import SwiftUI

public protocol TAAnalyticsView: View {
    associatedtype ViewBody : View
    
    @ViewBuilder @MainActor var viewBody: Self.ViewBody { get }
    
    var analyticsView: ViewAnalyticsModel { get }
    
    var taAnalytics: TAAnalytics { get }
}

public extension TAAnalyticsView {
    @ViewBuilder
    @MainActor
    var body: some View {
        viewBody
            .onFirstAppear {
                taAnalytics.track(viewShow: analyticsView)
            }
            .environmentObject(analyticsView)
    }
}
