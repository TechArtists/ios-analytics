//  TAAnalytics+UI.swift
//  Created by Adi on 10/25/22
//
//  Copyright (c) 2022 Tech Artists Agency SRL (http://TA.com/)
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

import Foundation

// MARK: -

/// Defines specific events for showing views & tapping buttons
public protocol TAAnalyticsUIProtocol: TAAnalyticsBaseProtocol, TAAnalyticsStuckUIProtocol {
    /// Sends an `ui_view_show` event  and sets up a timer to detect if the user is stuck on the view.
    ///
    /// The EventAnalyticsModel has the following parameters:
    ///
    ///      name: String
    ///      type: String?
    ///      group_name: String?
    ///      group_order: String?
    ///      group_stage: String?
    ///      parent_view_{name, type, group_name, group_order, group_stage}: String?
    ///
    /// - Parameters:
    ///   - viewShow: the view that was just shown
    ///  - stuckTimer: The duration in seconds after which an `error_stuck_on_ui_view_show` event is triggered if the user remains on the view.
    func track(viewShow view: ViewAnalyticsModel, stuckTimer: TimeInterval?)
    
    /// Sends an `ui_button_tap` event.
    ///
    /// The EventAnalyticsModel has the following parameters:
    ///
    ///      name: String
    ///      extra: String?
    ///      order: Int?, that is 1-based. It is equal to `index + 1`
    ///      view_{name, type, group_name, group_order, group_stage}: String?
    ///      parent_view_{name, type, group_name, group_order, group_stage}: String?
    ///      where view_name is Mandatory
    ///
    /// - Parameters:
    ///   - symbolicName: usually use the symbolic name of the button, not the actual localized name (e.g. "Subscribe", event though the button might be called "Try Free Before Subscribing"
    ///   - view: the view the button has been shown on
    ///   - extra: any extra information that should be attached (e.g. Maybe once users "Subscribe", you want to also know the subscription plan they are subscribing to. That plan id, can go into `extra`)
    ///   - index: this should be 0 based, but it will be sent with an offset of +1. So the first item in the list, will have index=0, but will appear in analytics as 1.
    func track(buttonTap symbolicName: String, onView view: ViewAnalyticsModel, extra: String?, index: Int?)
    
    var lastParentViewShown: ViewAnalyticsModel? { get set}
}

// MARK: - Default Implementations

public extension TAAnalyticsUIProtocol {

    func track(viewShow view: ViewAnalyticsModel, stuckTimer: TimeInterval? = nil) {
        cancelStuckTimer()
        trackCorrectedStuckEventIfNeeded(viewName: view.name)

        let params = buildParameters(for: view)

        if let stuckTimer {
            UserDefaults.standard.set(params, forKey: stuckViewParamsKey)

            if view.parentView == nil {
                scheduleStuckTimer(delay: stuckTimer, viewName: view.name)
            }
        }

        if view.parentView == nil {
            lastParentViewShown = view
            set(userProperty: .LAST_PARENT_VIEW_SHOWN, to: formatLastParentView(view))
        }

        track(event: .ui_view_show, params: params, logCondition: .logAlways)
    }
    
    func track(buttonTap symbolicName: String, onView view: ViewAnalyticsModel, extra: String? = nil, index: Int? = nil){
        var params = [String: (any AnalyticsBaseParameterValue)]()
        
        params["name"] = symbolicName
        if let index = index {
            params["order"] = index + 1
        }
        if let extra = extra {
            params["extra"] = extra
        }
        
        addParameters(for: view, to: &params, prefix: "view_")
        if let parentView = view.parentView {
            addParameters(for: parentView, to: &params, prefix: "parent_view_")
        }

        track(event: .UI_BUTTON_TAP, params: params, logCondition: .logAlways)
    }
    
    private func buildParameters(for view: ViewAnalyticsModel) -> [String: (any AnalyticsBaseParameterValue)] {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        addParameters(for: view, to: &params, prefix: "")

        if let parentView = view.parentView {
            addParameters(for: parentView, to: &params, prefix: "parent_view_")
        }

        return params
    }
    
    private func formatLastParentView(_ view: ViewAnalyticsModel) -> String {
        return "\(view.name);\(String(describingOptional: view.type));\(String(describingOptional: view.groupDetails?.name));\(String(describingOptional: view.groupDetails?.order));\(String(describingOptional: view.groupDetails?.stage))"
    }
    
    internal func addParameters(for view: ViewAnalyticsModel, to params: inout [String: (any AnalyticsBaseParameterValue)], prefix: String) {
        params["\(prefix)name"] = view.name

        if let type = view.type {
            params["\(prefix)type"] = type
        }

        if let groupDetails = view.groupDetails {
            params["\(prefix)group_name"] = groupDetails.name
            params["\(prefix)group_order"] = groupDetails.order
            params["\(prefix)group_stage"] = groupDetails.stage.description
        }
    }
}

// MARK: - Empty Conformance

extension TAAnalytics: TAAnalyticsUIProtocol {}
