//  AppDelegate.swift
//  Created by Adi on 10/25/22.
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
import UIKit
import CoreTelephony
import TAAnalyticsFirebaseConsumer

import TAAnalytics

extension AnalyticsEvent {
    static let DID_RECEIVE_MEMORY_WARNING = AnalyticsEvent("did_receive_memory_warning")
    static let CALL_PLACED = AnalyticsEvent("call_placed")
}

extension AnalyticsUserProperty {
    static let INSTALL_ORIENTATION = AnalyticsUserProperty("install_orientation")
}

extension AnalyticsView {
    static let CONTACTS_PERMISSION_DENIED         = AnalyticsView(name: "contacts", type: "permission denied")
    static let CONTACTS_PERMISSION_NOT_DETERMINED = AnalyticsView(name: "contacts", type: "permission not determined")
    static let CONTACTS_WITH_PERMISSION           = AnalyticsView(name: "contacts") // or type:"with permission"

    /// the type will be set at runtime, as the id of the user
    static let CONTACT = AnalyticsView("contact")
}

@objc class AppDelegate: NSObject, UIApplicationDelegate {
    
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        
    }
    
    var analytics: TAAnalytics!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        UITableView.appearance().backgroundColor = UIColor.clear

        let config = TAAnalyticsConfig(analyticsVersion: "1.0",
                                       consumers: [
                                                OSLogAnalyticsConsumer(),
                                                EventEmitterConsumer(),
                                                FirebaseAnalyticsConsumer()
                                       ]
                                    )
        analytics = TAAnalytics(config: config)
        Task {
            await analytics.start(customInstallUserPropertiesCompletion: {
                self.analytics.set(userProperty: .INSTALL_ORIENTATION, to: UIDevice.current.orientation.rawValue.description)
            })
        }
        
        // the `ob_first_open` event that will be sent will have the "install_orientation" user property already set, before being set

        // TODO: also send an event
        
        return true
    }
}
