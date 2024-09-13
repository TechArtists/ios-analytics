//  AnalyticsParameterValue.swift
//  Created by Adi on 10/24/22
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

// TODO: Move in Firebase so that anyone can write their own converter
/// Firebase only accepts Strings & NSNumbers as parameter values
public protocol AnalyticsPlatformParameterValue {}


/// AnalyticsBase accepts any String/Int/Double/Float/Boolean
/// that it then convert to String/NSNumber so that Firebase can digest it
public protocol AnalyticsBaseParameterValue: CustomStringConvertible {
}

// When adding any new conformances, make sure to update all existing AnalyticsPlatform#convert methods

extension String: AnalyticsBaseParameterValue {}

extension Int: AnalyticsBaseParameterValue {}
extension Double: AnalyticsBaseParameterValue {}
extension Float: AnalyticsBaseParameterValue {}
extension Bool: AnalyticsBaseParameterValue {}

extension NSNumber: AnalyticsBaseParameterValue {}
