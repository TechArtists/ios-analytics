//
//  TAAnalyticsBundleMetadataTests.swift
//  TAAnalytics
//
//  Created by OpenAI on 06.07.2026.
//

import Testing
@testable import TAAnalytics

@Test
func bundleIdentifierFallsBackWhenMissingOrEmpty() {
    #expect(BundleAnalyticsMetadata.bundleIdentifier(nil) == "unknown.bundle")
    #expect(BundleAnalyticsMetadata.bundleIdentifier("   ") == "unknown.bundle")
    #expect(BundleAnalyticsMetadata.bundleIdentifier("com.example.app") == "com.example.app")
}

@Test
func displayNameFallsBackThroughKnownBundleFields() {
    #expect(BundleAnalyticsMetadata.displayName(displayName: "Main App", bundleName: "Bundle Name", bundleIdentifier: "com.example.app") == "Main App")
    #expect(BundleAnalyticsMetadata.displayName(displayName: nil, bundleName: "Bundle Name", bundleIdentifier: "com.example.app") == "Bundle Name")
    #expect(BundleAnalyticsMetadata.displayName(displayName: "  ", bundleName: nil, bundleIdentifier: "com.example.app") == "com.example.app")
    #expect(BundleAnalyticsMetadata.displayName(displayName: nil, bundleName: nil, bundleIdentifier: nil) == "unknown.bundle")
}

@Test
func buildVersionFallsBackToShortVersion() {
    #expect(BundleAnalyticsMetadata.buildVersion(buildVersion: "123", shortVersion: "1.2.3") == "123")
    #expect(BundleAnalyticsMetadata.buildVersion(buildVersion: nil, shortVersion: "1.2.3") == "1.2.3")
    #expect(BundleAnalyticsMetadata.buildVersion(buildVersion: " ", shortVersion: nil) == "unknown_version")
}

@Test
func installVersionFallsBackToBuildVersion() {
    #expect(BundleAnalyticsMetadata.installVersion(shortVersion: "1.2.3", buildVersion: "123") == "1.2.3")
    #expect(BundleAnalyticsMetadata.installVersion(shortVersion: nil, buildVersion: "123") == "123")
    #expect(BundleAnalyticsMetadata.installVersion(shortVersion: " ", buildVersion: nil) == nil)
}
