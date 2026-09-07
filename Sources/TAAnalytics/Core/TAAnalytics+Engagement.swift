//  TAAnalytics+UI.swift
//  Created by Adi on 10/25/22
//
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

import Foundation

// MARK: -

/// Defines specific events for showing views & tapping buttons
public protocol TAAnalyticsEngagementProtocol: TAAnalyticsBaseProtocol {

    /// Sends an `engagement` event with these parameters:
    ///
    ///      name: String
    ///      view_{name, type, funnel_name, funnel_step, funnel_step_is_optional, funnel_step_is_final}: String?
    ///
    /// Custom parameters are merged after the automatically generated `view_*`
    /// ones, so a call site can override them.
    ///
    /// - Parameters:
    ///   - engagement: the name for this engagement (e.g. for a fitness app it can be "start workout" or "end workout")
    ///   - extraParams: extra analytics parameters to merge into the payload
    @available(*, deprecated, message: "Pass an EventAnalyticsModel instead, so the event name stays a centralized constant")
    func track(
        engagement: String,
        extraParams: [String: (any AnalyticsBaseParameterValue)]?
    )

    /// Sends both `engagement_primary` & `engagement` events, with the same
    /// parameters as ``track(engagement:extraParams:)``.
    ///
    /// - Parameters:
    ///   - engagementPrimary: the name for this engagement (e.g. for a fitness app it can be "start workout" or "end workout")
    ///   - extraParams: extra analytics parameters to merge into the payload
    @available(*, deprecated, message: "Pass an EventAnalyticsModel instead, so the event name stays a centralized constant")
    func track(
        engagementPrimary: String,
        extraParams: [String: (any AnalyticsBaseParameterValue)]?
    )
}

public extension TAAnalyticsEngagementProtocol {

    @available(*, deprecated, message: "Pass an EventAnalyticsModel instead, so the event name stays a centralized constant")
    func track(
        engagement: String,
        extraParams: [String: (any AnalyticsBaseParameterValue)]?
    ) {
        sendEngagement(named: engagement, onView: nil, extraParams: extraParams)
    }

    @available(*, deprecated, message: "Pass an EventAnalyticsModel instead, so the event name stays a centralized constant")
    func track(
        engagementPrimary: String,
        extraParams: [String: (any AnalyticsBaseParameterValue)]?
    ) {
        sendPrimaryEngagement(named: engagementPrimary, onView: nil, extraParams: extraParams)
    }

    /// Sends an `engagement` event.
    ///
    /// - Parameters:
    ///   - view: the view this engagement belongs to. Passing `nil` attributes it
    ///   to `lastViewShow` instead, which only follows `ui_view_show` events: with
    ///   `.firstAppearance` tracking that still points at a previously visited
    ///   screen after a back navigation, so pass the view whenever the call site
    ///   knows it.
    @available(*, deprecated, message: "Pass an EventAnalyticsModel instead, so the event name stays a centralized constant")
    func track(
        engagement: String,
        onView view: (any ViewAnalyticsModelProtocol)? = nil,
        extraParams: [String: (any AnalyticsBaseParameterValue)]? = nil
    ) {
        sendEngagement(named: engagement, onView: view, extraParams: extraParams)
    }

    func track(
        engagement: EventAnalyticsModel,
        onView view: (any ViewAnalyticsModelProtocol)? = nil,
        extraParams: [String: (any AnalyticsBaseParameterValue)]? = nil
    ) {
        sendEngagement(named: engagement.rawValue, onView: view, extraParams: extraParams)
    }

    /// Sends both `engagement_primary` & `engagement` events.
    ///
    /// - Parameters:
    ///   - view: the view this engagement belongs to. Passing `nil` attributes it
    ///   to `lastViewShow` instead, which only follows `ui_view_show` events: with
    ///   `.firstAppearance` tracking that still points at a previously visited
    ///   screen after a back navigation, so pass the view whenever the call site
    ///   knows it.
    @available(*, deprecated, message: "Pass an EventAnalyticsModel instead, so the event name stays a centralized constant")
    func track(
        engagementPrimary: String,
        onView view: (any ViewAnalyticsModelProtocol)? = nil,
        extraParams: [String: (any AnalyticsBaseParameterValue)]? = nil
    ) {
        sendPrimaryEngagement(named: engagementPrimary, onView: view, extraParams: extraParams)
    }

    func track(
        engagementPrimary: EventAnalyticsModel,
        onView view: (any ViewAnalyticsModelProtocol)? = nil,
        extraParams: [String: (any AnalyticsBaseParameterValue)]? = nil
    ) {
        sendPrimaryEngagement(named: engagementPrimary.rawValue, onView: view, extraParams: extraParams)
    }

    /// Sends `engagement`. Every public entry point funnels through here, so the
    /// deprecated `String` overloads add no behaviour of their own.
    private func sendEngagement(
        named name: String,
        onView view: (any ViewAnalyticsModelProtocol)?,
        extraParams: [String: (any AnalyticsBaseParameterValue)]?
    ) {
        track(
            event: .ENGAGEMENT,
            params: engagementParams(name: name, onView: view, extraParams: extraParams),
            logCondition: .logAlways
        )
    }

    /// Sends `engagement_primary` alongside the companion `engagement` event.
    private func sendPrimaryEngagement(
        named name: String,
        onView view: (any ViewAnalyticsModelProtocol)?,
        extraParams: [String: (any AnalyticsBaseParameterValue)]?
    ) {
        let params = engagementParams(name: name, onView: view, extraParams: extraParams)

        track(event: .ENGAGEMENT, params: params, logCondition: .logAlways)
        track(event: .ENGAGEMENT_PRIMARY, params: params, logCondition: .logAlways)
    }

    /// Builds the shared `engagement`/`engagement_primary` payload.
    ///
    /// `view` attributes the engagement explicitly; passing `nil` falls back to
    /// `lastViewShow`. Extra parameters are merged last so a call site can override
    /// the automatically generated ones.
    private func engagementParams(
        name: String,
        onView view: (any ViewAnalyticsModelProtocol)?,
        extraParams: [String: (any AnalyticsBaseParameterValue)]?
    ) -> [String: (any AnalyticsBaseParameterValue)] {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        params["name"] = name

        if let analyticsUI = self as? any TAAnalyticsUIProtocol {
            switch view ?? analyticsUI.lastViewShow {
            case let view as ViewAnalyticsModel:
                analyticsUI.addParameters(for: view, to: &params, prefix: "view_")
            case let secondaryView as SecondaryViewAnalyticsModel:
                params["secondary_view_name"] = secondaryView.name
                if let type = secondaryView.type {
                    params["secondary_view_type"] = type
                }
                analyticsUI.addParameters(for: secondaryView.mainView, to: &params, prefix: "view_")
            default:
                break
            }
        }

        if let extraParams {
            params.merge(extraParams) { _, new in new }
        }

        return params
    }
}

// MARK: - Empty Conformance

extension TAAnalytics: TAAnalyticsEngagementProtocol {}
