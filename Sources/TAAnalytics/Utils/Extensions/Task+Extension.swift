//
//  Task+Extension.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 19.09.2024.
//


extension Task where Success == Never, Failure == Never {
    // Sleep for a given number of seconds
    public static func sleep(seconds: Double) async throws {
        let nanoseconds = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}
