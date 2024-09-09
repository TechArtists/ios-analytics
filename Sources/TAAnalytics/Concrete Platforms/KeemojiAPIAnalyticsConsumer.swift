//  KeemojiAPIAnalyticsConsumer.swift
//  Created by Adi on 11/9/22
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
//
import Foundation
import UIKit
import OSLog

// TODO: No !

//extension AnalyticsConsumer {
//    public static let keemojiAPI = KeemojiAPIAnalyticsConsumer()
//}

public class KeemojiAPIAnalyticsConsumer: AnalyticsConsumer, AnalyticsConsumerWithWriteOnlyUserID {
    var debugServerGlobalCounter: Int = 0
    var debugServerFailedURLRequests = [(URLRequest, String?)]()

    weak var userDefaults: UserDefaults? = nil
    weak var TAAnalytics: TAAnalytics? = nil
    
    lazy var userIDForInstance: String = {
        if let userID = self.TAAnalytics?.userID {
            return userID
        }
        if let userPseudoID = self.TAAnalytics?.userPseudoID {
            return userPseudoID
        }
        if let myRandomUUID = self.userDefaults?.string(forKey: "keemojiAPIRandomUUID") {
            return myRandomUUID
        }
        let myRandomUUID = UUID().description
        self.userDefaults?.set(myRandomUUID, forKey: "keemojiAPIRandomUUID")
        return myRandomUUID
    }()
    
    enum DebugServerEndpoint: String {
        case sendEvent = "sendEvent"
        case setUserProperty = "setUserProperty"
    }
    
    public func maybeStartFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, TAAnalytics: TAAnalytics) -> Bool {
        if installType != .AppStore {
            self.userDefaults = userDefaults
            self.TAAnalytics = TAAnalytics
            return true
        }
        return false
    }
    
    public func log(event: AnalyticsEvent, params: [String : AnalyticsBaseParameterValue]?) {
        var jsonParams = [String: Any]()
        jsonParams["name"] = event.rawValue
        jsonParams["parameters"] = params

        sendToDebugServer(endpoint: .sendEvent, postData: jsonParams)
    }
    
    public func set(userProperty: AnalyticsUserProperty, to: String?) {
        var jsonParams = [String: Any]()
        jsonParams["name"] = userProperty.rawValue
        jsonParams["value"] = to

        sendToDebugServer(endpoint: .setUserProperty, postData: jsonParams)
    }
    
    public func set(usertID: String?) {
        sendUserIDToDebugServer(userID: usertID)
    }
    
    // MARK: Server stuff
    
    func sendUserIDToDebugServer(userID: String?){
        var jsonParams = [String: Any]()
        jsonParams["name"] = "user_id"
        jsonParams["value"] = userID ?? "nil"
        sendToDebugServer(endpoint: .setUserProperty, postData: jsonParams)
    }

    
    
    func sendToDebugServer(endpoint: DebugServerEndpoint, postData: [String:Any]){
        let osVersion = ProcessInfo().operatingSystemVersion
        let osVersionString = "\(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"

        var postData = postData
        postData["platform"] = "iOS"
        postData["appID"] = Bundle.main.bundleIdentifier!
        postData["seqID"] = debugServerGlobalCounter
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withFullDate,
            .withFullTime,
            .withTimeZone,
            .withFractionalSeconds
        ]
        postData["clientTS"] = formatter.string(for:Date())
        
        debugServerGlobalCounter += 1

        var deviceName = UIDevice.current.name
        #if targetEnvironment(simulator)
            deviceName = "Simulator " + deviceName
        #endif
        
//        var url = URLComponents(string: "http://10.0.1.127:8080/analyticsdebugview/v1/\(endpoint.rawValue)")!
        var url = URLComponents(string: "https://api.keemoji.com/analyticsdebugview/v1/\(endpoint.rawValue)")!
        url.queryItems = [URLQueryItem(name: "userID", value: self.userIDForInstance),
                          URLQueryItem(name: "deviceName", value: deviceName),
                          URLQueryItem(name: "appName", value:    (Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")! as! String)),
                          URLQueryItem(name: "appVersion", value: (Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")! as! String)),
                          URLQueryItem(name: "osVersion", value: osVersionString)
        ]
        
        var request = URLRequest(url: url.url!)
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: postData, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        
        os_log("Sending to debug server %{public}@", log: LOGGER, type: .info, String(describingOptional: postData["name"]))
        self.debugServerFailedURLRequests.forEach { sendToDebugServer(urlRequest: $0.0, name: $0.1, hasFailedAlready: true) }
        sendToDebugServer(urlRequest: request, name: postData["name"] as? String, hasFailedAlready: false)
    }
    
    private func sendToDebugServer(urlRequest: URLRequest, name: String?, hasFailedAlready: Bool){
        let task = URLSession.shared.dataTask(with: urlRequest) { maybeData, maybeResponse, maybeError in
            
            if let error = maybeError {
                os_log("Found error when sending name: %{public}@, error: %{public}@", log: LOGGER, type: .error, String(describingOptional: name),  String(describingOptional: error))
                
                if (error as NSError).domain == NSURLErrorDomain {
                    if !hasFailedAlready {
                        os_log("Adding to stale queue", log: LOGGER, type: .error)
                        self.debugServerFailedURLRequests.append((urlRequest, name))
                    } else {
                        os_log("Not adding to stale queue", log: LOGGER, type: .error)
                    }
                }
            } else {
                if hasFailedAlready {
                    os_log("   Sent stale to debug server %@", log: LOGGER, type: .error, String(describingOptional: name))
                    self.debugServerFailedURLRequests.removeAll(where: { $0 == (urlRequest, name) })
                } else {
                    os_log("   Sent to debug server %@", log: LOGGER, type: .error, String(describingOptional: name))
                }
            }
        }
        task.resume()
    }
    
}
