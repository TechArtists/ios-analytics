//  KeemojiAPIAnalyticsAdaptor.swift
//  Created by Adi on 11/9/22
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
import UIKit
import OSLog

public enum InstallTypeError: Error {
    case invalidInstallType
}

public class WebDebugAdaptor: AnalyticsAdaptor, AnalyticsAdaptorWithWriteOnlyUserID {
    public typealias T = WebDebugAdaptor

    var debugServerGlobalCounter: Int = 0
    var debugServerFailedURLRequests = [(URLRequest, String?)]()

    weak var userDefaults: UserDefaults? = nil
    weak var taAnalytics: TAAnalytics? = nil
    
    public init() {}
    
    lazy var userIDForInstance: String = {
        if let userID = self.taAnalytics?.userID {
            return userID
        }
        if let userPseudoID = self.taAnalytics?.userPseudoID {
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
    
    public func startFor(installType: TAAnalyticsConfig.InstallType, userDefaults: UserDefaults, taAnalytics: TAAnalytics) async throws {
        if installType != .AppStore {
            self.userDefaults = userDefaults
            self.taAnalytics = taAnalytics
        } else {
            throw InstallTypeError.invalidInstallType
        }
    }
    
    public func track(trimmedEvent: EventAnalyticsModelTrimmed, params: [String : any AnalyticsBaseParameterValue]?) {
        var jsonParams = [String: Any]()
        jsonParams["name"] = trimmedEvent.rawValue
        jsonParams["parameters"] = params

        sendToDebugServer(endpoint: .sendEvent, postData: jsonParams)
    }
    
    public func trim(event: EventAnalyticsModel) -> EventAnalyticsModelTrimmed {
        EventAnalyticsModelTrimmed(event.rawValue.ta_trim(toLength: 40, debugType: "event"))
    }
    
    public func trim(userProperty: UserPropertyAnalyticsModel) -> UserPropertyAnalyticsModelTrimmed {
        UserPropertyAnalyticsModelTrimmed(userProperty.rawValue.ta_trim(toLength: 24, debugType: "user property"))
    }
    
    public func set(trimmedUserProperty: UserPropertyAnalyticsModelTrimmed, to: String?) {
        var jsonParams = [String: Any]()
        jsonParams["name"] = trimmedUserProperty.rawValue
        jsonParams["value"] = to

        sendToDebugServer(endpoint: .setUserProperty, postData: jsonParams)
    }
    
    public func set(userID: String?) {
        sendUserIDToDebugServer(userID: userID)
    }
    
    public var wrappedValue: Self {
        self
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

        
        TALogger.log("Sending to debug server \(String(describingOptional: postData["name"]))", level: .info)
        self.debugServerFailedURLRequests.forEach { sendToDebugServer(urlRequest: $0.0, name: $0.1, hasFailedAlready: true) }
        sendToDebugServer(urlRequest: request, name: postData["name"] as? String, hasFailedAlready: false)
    }
    
    private func sendToDebugServer(urlRequest: URLRequest, name: String?, hasFailedAlready: Bool){
        let task = URLSession.shared.dataTask(with: urlRequest) { maybeData, maybeResponse, maybeError in
            
            if let error = maybeError {
                TALogger.log("Found error when sending name: \(String(describingOptional: name)), error: \(String(describingOptional: error))", level: .error)
                
                if (error as NSError).domain == NSURLErrorDomain {
                    if !hasFailedAlready {
                        TALogger.log("Adding to stale queue", level: .error)
                        self.debugServerFailedURLRequests.append((urlRequest, name))
                    } else {
                        TALogger.log("Not adding to stale queue", level: .error)
                    }
                }
            } else {
                if hasFailedAlready {
                    TALogger.log("Sent stale to debug server \(String(describingOptional: name))", level: .error)
                    self.debugServerFailedURLRequests.removeAll(where: { $0 == (urlRequest, name) })
                } else {
                    TALogger.log("Sent to debug server \(String(describingOptional: name))", level: .error)

                }
            }
        }
        task.resume()
    }
    
}
