//  DefaultInstallUserPropertiesCalculator.swift
//  Created by Adi on 10/24/22
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
import UIKit
import OSLog

class DefaultInstallUserPropertiesCalculator {
    
    let analytics: TAAnalyticsBaseProtocol
    let userPropertiesToCalculate: [AnalyticsUserProperty]
    
    init(analytics: TAAnalyticsBaseProtocol, userPropertiesToCalculate: [AnalyticsUserProperty]){
        self.analytics = analytics
        self.userPropertiesToCalculate = userPropertiesToCalculate
    }
    
    func calculateUserPropertiesAndSetThem() {
        for userProperty in userPropertiesToCalculate {
            switch userProperty {
            case .INSTALL_DATE:
                setInstallDate()
            case .INSTALL_VERSION:
                setInstallVersion()
            case .INSTALL_PLATFORM_VERSION:
                setInstallPlatformVersion()
            case .INSTALL_IS_JAILBROKEN:
                setInstallIsJailbroken()
            case .INSTALL_DYNAMIC_TYPE:
                setInstallDynamicType()
            case .INSTALL_UI_APPEARANCE:
                setInstallUIAppearance()
            default:
                os_log("No mapping defined for install user property %{public}@"
                       , log: LOGGER
                       , type: .error
                       , userProperty.rawValue)
            }
        }
    }
    
    private func setInstallDate() {
        let now = Date()
        
        let options: ISO8601DateFormatter.Options = [.withFullDate, .withDashSeparatorInDate]
        let s = ISO8601DateFormatter.string(from: now, timeZone: TimeZone(abbreviation: "UTC")!, formatOptions: options)
        analytics.set(userProperty: .INSTALL_DATE, to: s)
    }
    
    private func setInstallVersion() {
        let installVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String)
        analytics.set(userProperty: .INSTALL_VERSION, to: installVersion)
    }
    
    private func setInstallPlatformVersion() {
        let v = ProcessInfo().operatingSystemVersion
        let vString = "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
        analytics.set(userProperty: .INSTALL_PLATFORM_VERSION, to: vString)
    }

    private func setInstallIsJailbroken() {
        let isJailbroken = UIApplication.shared.canOpenURL(URL(string: "cydia://package/com.an.example.package")!) ? "true" : "false"
        analytics.set(userProperty: .INSTALL_IS_JAILBROKEN, to: isJailbroken)
    }
    private func setInstallUIAppearance() {
        let vc = UIViewController()
        let uiAppearance: String
        if #available(iOS 12.0, *) {
            uiAppearance = vc.traitCollection.userInterfaceStyle.debugDescription
        } else {
            uiAppearance = "light/dark mode not available"
        }
        analytics.set(userProperty: .INSTALL_UI_APPEARANCE, to: uiAppearance)
    }
    private func setInstallDynamicType() {
        let dynamicType = UIApplication.shared.preferredContentSizeCategory.debugDescription
        analytics.set(userProperty: .INSTALL_DYNAMIC_TYPE, to: dynamicType)
    }
}


@available(iOS 12.0, *)
extension UIUserInterfaceStyle  : @retroactive CustomDebugStringConvertible{
    public var debugDescription: String {
        switch self {
        case .unspecified: return "unspecified"
        case .light: return "light"
        case .dark: return "dark"
        @unknown default: return "unknown"
        }
    }
}

extension UIContentSizeCategory: @retroactive CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .unspecified:
            return "Unspecified"
        case .extraSmall:
            return "XS"
        case .small:
            return "S"
        case .medium:
            return "M"
        case .large:
            return "L"
        case .extraLarge:
            return "XL"
        case .extraExtraLarge:
            return "XXL"
        case .extraExtraExtraLarge:
            return "XXXL"
        case .accessibilityMedium:
            return "A11Y-M"
        case .accessibilityLarge:
            return "A11Y-L"
        case .accessibilityExtraLarge:
            return "A11Y-XL"
        case .accessibilityExtraExtraLarge:
            return "A11Y-XXL"
        case .accessibilityExtraExtraExtraLarge:
            return "A11Y-XXXL"
        default:
            return "error_\(self.rawValue)"
        }
    }
}
