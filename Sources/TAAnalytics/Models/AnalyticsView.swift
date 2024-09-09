//  AnalyticsView.swift
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

///   - parentView: the parent view of this view. If you're showing a full screen view controller, then this should be nil. If you want to track when a specific error message label has been shown, then in that case the `parentView` should be the filled.
public class AnalyticsView: Hashable, Equatable {
    public let name: String
    public let type: String?
    
    public let parentView: AnalyticsView?
    
    public init(_ name: String){
        self.name = name
        self.type = nil
        self.parentView = nil
    }
    
    public init(name: String){
        self.name = name
        self.type = nil
        self.parentView = nil
    }
    
    public init(name: String, type: String?){
        self.name = name
        self.type = type
        self.parentView = nil
    }
    
    public init(name: String, type: String?, parentView: AnalyticsView){
        self.name = name
        self.type = type
        self.parentView = parentView
    }
    
    public func withType(type: String?) -> AnalyticsView {
        return AnalyticsView(name: name, type: type)
    }
    
    public static func == (lhs: AnalyticsView, rhs: AnalyticsView) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type && lhs.parentView == rhs.parentView
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(parentView)
    }

    

}
