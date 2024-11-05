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
public protocol TAAnalyticsUIProtocol: TAAnalyticsBaseProtocol {
    
    /// Sends an `ui_view_shown` event.
    ///
    /// The AnalyticsEvent has the following parameters:
    ///
    ///      name: String
    ///      type: String?
    ///      group_name: String?
    ///      group_order: String?
    ///      group_stage: String?
    ///      parent_view_{name, type, group_name, group_order, group_stage}: String?
    ///
    /// - Parameters:
    ///   - viewShown: the view that was just shown
    func track(viewShown: AnalyticsView)
    
    /// Sends an `ui_button_tapped` event.
    ///
    /// The AnalyticsEvent has the following parameters:
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
    func track(buttonTapped symbolicName: String, onView view: AnalyticsView, extra: String?, index: Int?)
    
    var lastParentViewShown: AnalyticsView? { get set}
}

// MARK: - Default Implementations

public extension TAAnalyticsUIProtocol{

    func track(viewShown view: AnalyticsView) {
        var params = [String: (any AnalyticsBaseParameterValue)]()
        
        addParametersFor(view: view, params: &params, prefix: "")
        if let parentView = view.parentView {
            addParametersFor(view: parentView, params: &params, prefix: "parent_view_")
        } else {
            lastParentViewShown = view
            set(userProperty: .LAST_PARENT_VIEW_SHOWN, to: "\(view.name);\(String(describingOptional:view.type));\(String(describingOptional:view.groupDetails?.name));\(String(describingOptional:view.groupDetails?.order));\(String(describingOptional:view.groupDetails?.stage))")
        }
        
        track(event: .UI_VIEW_SHOWN, params: params, logCondition: .logAlways)
    }
    
    func track(buttonTapped symbolicName: String, onView view: AnalyticsView, extra: String? = nil, index: Int? = nil){
        var params = [String: (any AnalyticsBaseParameterValue)]()
        
        params["name"] = symbolicName
        if let index = index {
            params["order"] = index + 1
        }
        if let extra = extra {
            params["extra"] = extra
        }
        addParametersFor(view: view, params: &params, prefix: "view_")
        if let parentView = view.parentView {
            addParametersFor(view: parentView, params: &params, prefix: "parent_view_")
        }

        track(event: .UI_BUTTON_TAPPED, params: params, logCondition: .logAlways)
    }
    
    internal func addParametersFor(view: AnalyticsView, params: inout [String: (any AnalyticsBaseParameterValue)], prefix: String) {
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
