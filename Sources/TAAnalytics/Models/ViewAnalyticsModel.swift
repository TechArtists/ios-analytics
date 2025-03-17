/*
MIT License

Copyright (c) 2025 Tech Artists Agency

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

//  ViewAnalyticsModel.swift
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

///   - parentView: the parent view of this view. If you're showing a full screen view controller, then this should be nil. If you want to track when a specific error message label has been shown, then in that case the `parentView` should be the filled.
public class ViewAnalyticsModel: ObservableObject, Hashable, Equatable {
    public let name: String
    public let type: String?
    
    public let parentView: ViewAnalyticsModel?
    
    public let groupDetails: AnalyticsViewGroupDetails?
    
    public init(_ name: String){
        self.name = name
        self.type = nil
        self.parentView = nil
        self.groupDetails = nil
    }
    
    public init(name: String){
        self.name = name
        self.type = nil
        self.parentView = nil
        self.groupDetails = nil
    }
    
    public init(name: String, type: String?){
        self.name = name
        self.type = type
        self.parentView = nil
        self.groupDetails = nil
    }
    
    public init(name: String, type: String?, parentView: ViewAnalyticsModel){
        self.name = name
        self.type = type
        self.parentView = parentView
        self.groupDetails = nil
    }
    
    public init(name: String, type: String?, parentView: ViewAnalyticsModel, groupDetails: AnalyticsViewGroupDetails?) {
        self.name = name
        self.type = type
        self.parentView = parentView
        self.groupDetails = groupDetails
    }
    
    public init(name: String, type: String?, groupDetails: AnalyticsViewGroupDetails?){
        self.name = name
        self.type = type
        self.parentView = nil
        self.groupDetails = groupDetails
    }

    public func withType(type: String?) -> ViewAnalyticsModel {
        return ViewAnalyticsModel(name: name, type: type)
    }
    
    public static func == (lhs: ViewAnalyticsModel, rhs: ViewAnalyticsModel) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type && lhs.parentView == rhs.parentView
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(parentView)
    }
}

public class AnalyticsViewGroupDetails {
    public enum Stage: CustomStringConvertible {
        case start
        case middle
        case end // useful on the data to just see a minimal start -> end funnel

        public var description: String {
            switch self {
            case .start: return "start"
            case .middle: return "middle"
            case .end: return "end"
            }
        }
    }
    
    public let name: String
    public let order: Int
    public let stage: Stage
    
    public init(name: String, order: Int, isFinalScreen: Bool) {
        self.name = name
        self.order = order
        if order == 1 {
            self.stage = .start
        } else if isFinalScreen {
            self.stage = .end
        } else {
            self.stage = .middle
        }
    }
}
