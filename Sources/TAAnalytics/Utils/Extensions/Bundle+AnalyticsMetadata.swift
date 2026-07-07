//
//  Bundle+AnalyticsMetadata.swift
//  TAAnalytics
//
//  Created by OpenAI on 06.07.2026.
//

import Foundation

enum BundleAnalyticsMetadata {
    static func bundleIdentifier(_ bundleIdentifier: String?) -> String {
        nonEmpty(bundleIdentifier) ?? "unknown.bundle"
    }

    static func displayName(
        displayName: String?,
        bundleName: String?,
        bundleIdentifier: String?
    ) -> String {
        nonEmpty(displayName)
            ?? nonEmpty(bundleName)
            ?? nonEmpty(bundleIdentifier)
            ?? self.bundleIdentifier(nil)
    }

    static func buildVersion(
        buildVersion: String?,
        shortVersion: String?
    ) -> String {
        nonEmpty(buildVersion)
            ?? nonEmpty(shortVersion)
            ?? "unknown_version"
    }

    static func installVersion(
        shortVersion: String?,
        buildVersion: String?
    ) -> String? {
        nonEmpty(shortVersion) ?? nonEmpty(buildVersion)
    }

    private static func nonEmpty(_ value: String?) -> String? {
        guard let trimmedValue = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmedValue.isEmpty else {
            return nil
        }
        return trimmedValue
    }
}

extension Bundle {
    var taBundleIdentifier: String {
        BundleAnalyticsMetadata.bundleIdentifier(bundleIdentifier)
    }

    var taDisplayName: String {
        BundleAnalyticsMetadata.displayName(
            displayName: object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
            bundleName: object(forInfoDictionaryKey: "CFBundleName") as? String,
            bundleIdentifier: bundleIdentifier
        )
    }

    var taBuildVersion: String {
        BundleAnalyticsMetadata.buildVersion(
            buildVersion: object(forInfoDictionaryKey: "CFBundleVersion") as? String,
            shortVersion: object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        )
    }

    var taInstallVersion: String? {
        BundleAnalyticsMetadata.installVersion(
            shortVersion: object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            buildVersion: object(forInfoDictionaryKey: "CFBundleVersion") as? String
        )
    }
}
