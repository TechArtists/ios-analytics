//
//  TAButtonView.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 13.01.2025.
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

import SwiftUI

public struct TAAnalyticsButtonView<Label: View>: View {
    public let analyticsName: String
    public let analyticsView: ViewAnalyticsModel
    public let taAnalytics: TAAnalytics

    private let action: (() async -> Void)?
    private let labelBuilder: (_ isRunning: Bool) -> Label

    @State private var task: Task<Void, Never>? = nil

    public init(
        analyticsName: String,
        analyticsView: ViewAnalyticsModel,
        taAnalytics: TAAnalytics,
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping (_ isRunning: Bool) -> Label
    ) {
        self.analyticsName = analyticsName
        self.analyticsView = analyticsView
        self.taAnalytics = taAnalytics
        self.action = action
        self.labelBuilder = label
    }

    public var body: some View {
        Button {
            taAnalytics.track(buttonTap: analyticsName, onView: analyticsView)
            // Async path
            guard task == nil, let action else { return }

            task = Task {
                defer {
                    Task { @MainActor in
                        task = nil
                    }
                }

                await action()
            }
        } label: {
            labelBuilder(task != nil)
        }
        .opacity(task != nil ? 0.5 : 1.0)
        .overlay {
            if task != nil {
                ProgressView()
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .onDisappear {
            task?.cancel()
            task = nil
        }
        .disabled(task != nil)
    }
}
