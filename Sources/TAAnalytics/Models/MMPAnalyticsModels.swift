//
//  MMPAnalyticsModels.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 08.09.2026.
//  Copyright (c) 2026 Tech Artists Agency SRL
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

// MARK: - Mobile Measurement Partners
//
// An **MMP (Mobile Measurement Partner)** — AppsFlyer, Adjust, Branch, Singular — answers one
// question no single party can answer alone: which ad, if any, led to this install.
//
// The ad network sees the click. The app sees the install. The App Store sits between them and
// links neither, so nothing the app can observe on its own explains where a user came from. The
// MMP is the neutral third party wired into both ends. Neutrality is the point: ad networks
// self-report conversions, and asked separately two of them will each claim the same user. The
// MMP sees every network's clicks, so it can pick one winner and deduplicate the rest.
//
// How an attributed install comes together:
//
//   1. The ad network fires the MMP's tracking URL when the ad is tapped.
//   2. The user installs from the App Store. No identifier crosses that boundary.
//   3. The MMP's SDK, embedded in this app, reports the install on first launch.
//   4. The MMP matches install to click, and reports the result back — the payload modelled here.
//
// Step 4's precision depends on App Tracking Transparency. With consent the match is
// deterministic via the IDFA; without it the install falls back to SKAdNetwork's aggregated,
// delayed postbacks. This is why an MMP adaptor may hold its install postback open until the ATT
// prompt is answered, and why that timeout is generous rather than tight.
//
// Attribution also flows outward. Purchase and revenue events sent *to* the MMP are relayed on to
// the ad networks, which use them to bid toward users who look likely to convert. Revenue accuracy
// in an MMP adaptor therefore feeds ad targeting, not just reporting — over- or under-reporting
// teaches the networks to buy the wrong users.
//
// An install the MMP cannot tie to any click is **organic**: the user found the app themselves.

public extension UserPropertyAnalyticsModel {
    /// Acquisition channel for this install, or `"organic"`. Set on every launch, so any event in
    /// any adaptor can be split by where the user came from.
    static let MMP_ATTRIBUTED_NETWORK = UserPropertyAnalyticsModel("mmp_attributed_network")
    /// Acquisition campaign for this install, or `"organic"`.
    static let MMP_ATTRIBUTED_CAMPAIGN = UserPropertyAnalyticsModel("mmp_attributed_campaign")
}

public extension EventAnalyticsModel {
    /// The install itself, recorded once per install when the MMP resolves where it came from.
    static let MMP_ATTRIBUTED_FIRST_OPEN = EventAnalyticsModel("mmp_attributed_first_open")
}

/// An install's acquisition source, normalized away from any one MMP's payload shape.
///
/// Adaptors translate their vendor payload into this; TAAnalytics reports it under the
/// `mmp_attributed_*` names above, so every MMP produces the same fields.
public struct MMPAttribution: Sendable {

    /// Acquisition channel, or `"organic"` when the install was not attributed. Never empty.
    public let network: String
    /// Campaign, or `"organic"` when the install was not attributed. Never empty.
    public let campaign: String
    /// Whether the MMP found no click to credit, meaning the user arrived on their own.
    public let isOrganic: Bool
    /// Whether this payload describes the install itself rather than a later launch.
    ///
    /// MMPs resolve attribution once and then replay it from their own cache on every subsequent
    /// launch, so this is what keeps an install from being counted more than once.
    public let isFirstLaunch: Bool
    /// Vendor-named extras merged into `mmp_attributed_first_open`, letting an adaptor keep
    /// its own field names (`af_*`, `adjust_*`) without TAAnalytics knowing any of them.
    public let vendorParameters: [String: String]
    /// The untouched vendor payload, for consumers needing more than the normalized fields.
    public let raw: [String: String]

    public init(
        network: String,
        campaign: String,
        isOrganic: Bool,
        isFirstLaunch: Bool,
        vendorParameters: [String: String] = [:],
        raw: [String: String] = [:]
    ) {
        self.network = network
        self.campaign = campaign
        self.isOrganic = isOrganic
        self.isFirstLaunch = isFirstLaunch
        self.vendorParameters = vendorParameters
        self.raw = raw
    }
}

public extension TAAnalytics {

    /// Records an install's acquisition source: the network and campaign become user properties so
    /// any event can be split by channel, and the install itself is counted once.
    ///
    /// Safe to call on every launch — the first-open event is gated on
    /// ``MMPAttribution/isFirstLaunch``, which is false for a replay from the MMP's cache.
    @MainActor func trackMMPAttribution(_ attribution: MMPAttribution) {
        set(userProperty: .MMP_ATTRIBUTED_NETWORK, to: attribution.network)
        set(userProperty: .MMP_ATTRIBUTED_CAMPAIGN, to: attribution.campaign)

        guard attribution.isFirstLaunch else { return }

        var params: [String: (any AnalyticsBaseParameterValue)?] = [
            "attribution_network": attribution.network,
            "attribution_campaign": attribution.campaign
        ]
        for (key, value) in attribution.vendorParameters {
            params[key] = value
        }

        track(event: .MMP_ATTRIBUTED_FIRST_OPEN, params: params, logCondition: .logAlways)
    }
}
