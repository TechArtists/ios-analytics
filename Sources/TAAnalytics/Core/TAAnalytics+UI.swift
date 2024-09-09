//  TAAnalytics+UI.swift
//  Created by Adi on 10/25/22
//
//  Copyright (c) 2022 Tecj Artists Agenyc SRL (http://TA.com/)
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
    ///      view_name: String
    ///      view_type: String?
    ///      parent_view_name: String?
    ///      parent_view_type: String?
    ///
    /// - Parameters:
    ///   - viewShown: the view that was just shown
    func log(viewShown: AnalyticsView)
    
    /// Sends an `ui_button_tapped` event.
    ///
    /// The AnalyticsEvent has the following parameters:
    ///
    ///      name: String
    ///      view_name: String
    ///      view_type: String?
    ///      parent_view_name: String?
    ///      parent_view_type: String?
    ///      extra: String?
    ///      order: Int?, that is 1-based. It is equal to `index + 1`
    ///
    /// - Parameters:
    ///   - symbolicName: usually use the symbolic name of the button, not the actual localized name (e.g. "Subscribe", event though the button might be called "Try Free Before Subscribing"
    ///   - view: the view the button has been shown on
    ///   - extra: any extra information that should be attached (e.g. Maybe once users "Subscribe", you want to also know the subscription plan they are subscribing to. That plan id, can go into `extra`)
    ///   - index: this should be 0 based, but it will be sent with an offset of +1. So the first item in the list, will have index=0, but will appear in analytics as 1.
    func log(buttonTapped symbolicName: String, onView view: AnalyticsView, extra: String?, index: Int?)
}

// MARK: - Default Implementations

public extension TAAnalyticsUIProtocol{
    
    func log(viewShown: AnalyticsView) {
        var params = [String: AnalyticsBaseParameterValue]()
        params["view_name"] = viewShown.name
        if let type = viewShown.type {
            params["view_type"] = type
        }
        if let parentView = viewShown.parentView {
            params["parent_view_name"] = parentView.name
            if let type = parentView.type {
                params["parent_view_type"] = type
            }
        }
        log(event: .UI_VIEW_SHOWN, params: params, logCondition: .logAlways)
    }
    
    func log(buttonTapped symbolicName: String, onView view: AnalyticsView, extra: String? = nil, index: Int? = nil){
        var params = [String: AnalyticsBaseParameterValue]()
        params["name"] = symbolicName
        params["view_name"] = view.name
        if let screenType = view.type {
            params["view_type"] = screenType
        }
        if let parentView = view.parentView {
            params["parent_view_name"] = parentView.name
            if let type = parentView.type {
                params["parent_view_type"] = type
            }
        }
        if let index = index {
            params["order"] = index + 1
        }
        if let extra = extra {
            params["extra"] = extra
        }
        log(event: .UI_BUTTON_TAPPED, params: params, logCondition: .logAlways)
    }
}

// MARK: - Empty Conformance

extension TAAnalytics: TAAnalyticsUIProtocol {}
