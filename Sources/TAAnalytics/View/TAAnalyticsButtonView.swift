/*
MIT License

Copyright (c) 2025 Tech Artists Agency

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

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
