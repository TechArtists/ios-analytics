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
public protocol TAAnalyticsUIProtocol: TAAnalyticsBaseProtocol, TAAnalyticsStuckUIProtocol {
    /// Sends an `ui_view_show` event  and sets up a timer to detect if the user is stuck on the view.
    ///
    /// The EventAnalyticsModel has the following parameters:
    ///
    ///      name: String
    ///      type: String?
    ///      funnel_name: String?
    ///      funnel_step: Int?
    ///      funnel_step_is_optional: Bool?
    ///      funnel_step_is_final: Bool?
    ///
    /// - Parameters:
    ///   - viewShow: the view that was just shown
    ///   - stuckTimeout: The duration in seconds after which an `error (reason=stuck on ui_view_show, duration=)` event is triggered if the user remains on the view. If another view is shown after this duration finishes, an `error_corrected (reason=stuck on ui_view_show, duration=elapsed)` will be sent. For example, if you expect a transitory view like the splash screen to only be shown for 5 seconds, but it's shown after 7.5, this will send an `error (.. duration=5)` event followed by an `error_corrected (.. duration=7.5)` one.
    func track(viewShow view: ViewAnalyticsModel, stuckTimeout: TimeInterval?)
    
    /// Sends an `ui_view_show` event  for any secondary view that's shown inside/on top of a normal view.
    ///
    /// The EventAnalyticsModel has the following parameters:
    ///
    ///      secondary_view_name: String
    ///      secondary_view_type: String?
    ///      name: String
    ///      type: String?
    ///      funnel_name: String?
    ///      funnel_step: Int?
    ///      funnel_step_is_optional: Bool?
    ///      funnel_step_is_final: Bool?
    ///
    /// - Parameters:
    ///   - viewShow: the view that was just shown
    func track(viewShow secondaryView: SecondaryViewAnalyticsModel)

    /// Sends an `ui_button_tap` event.
    ///
    /// The EventAnalyticsModel has the following parameters:
    ///
    ///      name: String
    ///      detail: String?
    ///      is_default_detail: Bool?
    ///      order: Int?, that is 1-based. It is equal to `index + 1`
    ///      view_{name, type, funnel_name, funnel_step, funnel_step_is_optional, funnel_step_is_final}: String?
    ///      secondary_view_{name, type}: String?
    ///
    /// - Parameters:
    ///   - symbolicName: usually use the symbolic name of the button, not the actual localized name (e.g. "Subscribe", event though the button might be called "Try Free Before Subscribing"
    ///   - view: the view the button has been shown on
    ///   - detail: any extra detail that should be attached (e.g. Users that respond to on onboarding questionnaie and you  want to write down their resopnse, so "detail=male" for on an onboarding gender question)
    ///   - isDefaultDetail: if the extra details was already pre-selected (e.g. male was already checked) or if the user had to exlicitly select it
    ///   - index: this should be 0 based, but it will be sent with an offset of +1. So the first item in the list, will have index=0, but will appear in analytics as 1.
    func track(buttonTap symbolicName: String, onView view: any ViewAnalyticsModelProtocol, detail: String?, isDefaultDetail: Bool?, index: Int?)
    
    var lastViewShow: ViewAnalyticsModel? { get set}
}

// MARK: - Default Implementations

public extension TAAnalyticsUIProtocol {

    func track(viewShow view: ViewAnalyticsModel, stuckTimeout: TimeInterval? = nil) {
        self.stuckUIManager?.trackCorrectedStuckEventIfNeeded()
        self.stuckUIManager = nil

        var params = [String: (any AnalyticsBaseParameterValue)]()
        addParameters(for: view, to: &params, prefix: "")

        if let stuckTimeout {
            DispatchQueue.main.async {
                self.stuckUIManager = StuckUIManager(viewParams: params, initialDelay: stuckTimeout, analytics: self)
            }
        }

        lastViewShow = view
        set(userProperty: .LAST_VIEW_SHOW, to: formatLastViewShow(view))

        track(event: .UI_VIEW_SHOW, params: params, logCondition: .logAlways)
    }
    
    func track(viewShow secondaryView: SecondaryViewAnalyticsModel) {
        var params = [String: (any AnalyticsBaseParameterValue)]()

        params["secondary_view_name"] = secondaryView.name
        if let type = secondaryView.type {
            params["secondary_view_type"] = type
        }

        addParameters(for: secondaryView.mainView, to: &params, prefix: "")

        track(event: .UI_VIEW_SHOW, params: params, logCondition: .logAlways)
    }

    
    func track(buttonTap symbolicName: String, onView view: any ViewAnalyticsModelProtocol, detail: String? = nil, isDefaultDetail: Bool? = nil, index: Int? = nil){
        var params = [String: (any AnalyticsBaseParameterValue)]()
        
        params["name"] = symbolicName
        if let index = index {
            params["order"] = index + 1
        }
        if let detail = detail {
            params["detail"] = detail
        }
        if let isDefaultDetail = isDefaultDetail {
            params["is_default_detail"] = isDefaultDetail
        }
        
        if let view = view as? ViewAnalyticsModel {
            addParameters(for: view, to: &params, prefix: "view_")
        }
        else if let secondaryView = view as? SecondaryViewAnalyticsModel {
            params["secondary_view_name"] = secondaryView.name
            if let type = secondaryView.type {
                params["secondary_view_type"] = type
            }

            addParameters(for: secondaryView.mainView, to: &params, prefix: "view_")
        }
        
        track(event: .UI_BUTTON_TAP, params: params, logCondition: .logAlways)
    }
        
    private func formatLastViewShow(_ view: ViewAnalyticsModel) -> String {
        return "\(view.name);\(String(describingOptional: view.type));\(String(describingOptional: view.funnelStep?.funnelName));\(String(describingOptional: view.funnelStep?.step));\(String(describingOptional: view.funnelStep?.isOptionalStep));\(String(describingOptional: view.funnelStep?.isFinalStep))"
    }
    
    internal func addParameters(for view: ViewAnalyticsModel, to params: inout [String: (any AnalyticsBaseParameterValue)], prefix: String) {
        params["\(prefix)name"] = view.name

        if let type = view.type {
            params["\(prefix)type"] = type
        }

        if let funnelStepDetails = view.funnelStep {
            params["\(prefix)funnel_name"] = funnelStepDetails.funnelName
            params["\(prefix)funnel_step"] = funnelStepDetails.step
            params["\(prefix)funnel_step_is_optional"] = funnelStepDetails.isOptionalStep
            params["\(prefix)funnel_step_is_final"] = funnelStepDetails.isFinalStep
        }
    }
}

// MARK: - Empty Conformance

extension TAAnalytics: TAAnalyticsUIProtocol {}
