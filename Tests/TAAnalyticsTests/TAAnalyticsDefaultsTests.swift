//
//  TAAnalyticsDefaultsTests.swift
//  TAAnalytics
//
//  Created by Robert Tataru on 11.09.2024.
//

import Testing
import TAAnalytics
import UIKit

class TAAnalyticsDefaultsTests {

    var mockUserDefaults: UserDefaults!
    var yourClassInstance: TAAnalytics

    init() {
        UserDefaults.standard.removeSuite(named: "TestDefaults")
        mockUserDefaults = UserDefaults(suiteName: "TestDefaults")
        
        yourClassInstance = TAAnalytics(config: .init(analyticsVersion: "0", consumers: [], userDefaults: mockUserDefaults))
    }
    
    @Test
    func testStringFromUserDefaults() {
        let key = "testKey"
        let expectedValue = "TestString"
        
        mockUserDefaults.set(expectedValue, forKey: "\(TAAnalytics.userdefaultsKeyPrefix)_\(key)")
        
        let result = yourClassInstance.stringFromUserDefaults(forKey: key)
        
        #expect(result == expectedValue, "Expected to retrieve the correct string from UserDefaults")
    }
    
    @Test
    func testBoolFromUserDefaults() {
        let key = "testBoolKey"
        let expectedValue = true
        
        mockUserDefaults.set(expectedValue, forKey: "\(TAAnalytics.userdefaultsKeyPrefix)_\(key)")
        
        let result = yourClassInstance.boolFromUserDefaults(forKey: key)
       
        #expect(result == expectedValue, "Expected to retrieve the correct boolean value from UserDefaults")
    }

    @Test
    func testIntegerFromUserDefaults() {
        let key = "testIntegerKey"
        let expectedValue = 42
        
        mockUserDefaults.set(expectedValue, forKey: "\(TAAnalytics.userdefaultsKeyPrefix)_\(key)")
        
        let result = yourClassInstance.integerFromUserDefaults(forKey: key)
        
        #expect(result == expectedValue, "Expected to retrieve the correct integer value from UserDefaults")
    }

    @Test
    func testObjectFromUserDefaults() {
        let key = "testObjectKey"
        let expectedValue = ["key": "value"] as [String: String]
        
        mockUserDefaults.set(expectedValue, forKey: "\(TAAnalytics.userdefaultsKeyPrefix)_\(key)")
        
        let result = yourClassInstance.objectFromUserDefaults(forKey: key) as? [String: String]
        
        #expect(result == expectedValue, "Expected to retrieve the correct object from UserDefaults")
    }
    
    @Test
    func testSetInUserDefaults() {
        let key = "testSetKey"
        let valueToSet = "NewValue"
        
        yourClassInstance.setInUserDefaults(valueToSet, forKey: key)
        
        let storedValue = mockUserDefaults.string(forKey: "\(TAAnalytics.userdefaultsKeyPrefix)_\(key)")
        
        #expect(storedValue == valueToSet, "Expected to store the correct value in UserDefaults")
    }
}
