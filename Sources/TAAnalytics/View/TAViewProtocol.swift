//
//  TAView.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 13.01.2025.
//

import SwiftUI

public protocol TABaseView: View {
    associatedtype ViewBody : View
    
    @ViewBuilder @MainActor var viewBody: Self.ViewBody { get }
    
    let analyticsView: AnalyticsView { get }
    
    let taAnalytics: TAAnalytics { get }
}

public extension TABaseView {
    @ViewBuilder var body: some View {
        viewBody
            .onFirstAppear {
                taAnalytics.track(viewShown: analyticsView)
            }
    }
}
