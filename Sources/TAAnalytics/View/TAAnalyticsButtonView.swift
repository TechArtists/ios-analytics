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
    public let analyticsView: any ViewAnalyticsModelProtocol
    public let taAnalytics: TAAnalytics

    private let action: (() async -> Void)
    private let labelBuilder: (_ isRunning: Bool) -> Label

    /// How long we wait before showing the progress UI.
    private let progressDelay: Duration = .seconds(0.15)

    @State private var task: Task<Void, Never>? = nil
    @State private var showProgress: Bool = false

    // Sync version - preferred/simpler init
    public init(
        analyticsName: String,
        analyticsView: any ViewAnalyticsModelProtocol,
        taAnalytics: TAAnalytics,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.analyticsName = analyticsName
        self.analyticsView = analyticsView
        self.taAnalytics = taAnalytics
        self.action = { action() }
        self.labelBuilder = { _ in label() }
    }

    // Async version - explicitly named for clarity
    public init(
        analyticsName: String,
        analyticsView: any ViewAnalyticsModelProtocol,
        taAnalytics: TAAnalytics,
        asyncAction: @escaping () async -> Void,
        @ViewBuilder label: @escaping (_ isRunning: Bool) -> Label
    ) {
        self.analyticsName = analyticsName
        self.analyticsView = analyticsView
        self.taAnalytics = taAnalytics
        self.action = asyncAction
        self.labelBuilder = label
    }

    public var body: some View {
        let isActuallyRunning = (task != nil) // used for disabling / guarding
        let isVisiblyRunning = showProgress   // used for spinner / label state

        Button {
            guard task == nil else { return }

            taAnalytics.track(buttonTap: analyticsName, onView: analyticsView)

            // Reset progress immediately (no flash)
            showProgress = false

            task = Task {
                // A child task that flips showProgress after a delay
                let progressTask = Task {
                    try? await Task.sleep(for: progressDelay)
                    guard !Task.isCancelled else { return }
                    await MainActor.run { showProgress = true }
                }

                defer {
                    progressTask.cancel()
                    Task { @MainActor in
                        showProgress = false
                        task = nil
                    }
                }

                await action()
            }
        } label: {
            // Pass the delayed-running state so label changes together with spinner
            labelBuilder(isVisiblyRunning)
        }
        .disabled(isActuallyRunning)
        .opacity(isActuallyRunning ? 0.5 : 1.0)
        .overlay {
            if isVisiblyRunning {
                ProgressView()
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .onDisappear {
            task?.cancel()
            task = nil
            showProgress = false
        }
    }
}
