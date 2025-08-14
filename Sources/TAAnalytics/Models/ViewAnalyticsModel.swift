//  ViewAnalyticsModel.swift
//  Created by Adi on 10/24/22
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

public protocol ViewAnalyticsModelProtocol {}

public class SecondaryViewAnalyticsModel: ViewAnalyticsModelProtocol, ObservableObject, Hashable, Equatable {
    
    public let name: String
    public let type: String?
    
    public let mainView: ViewAnalyticsModel
    
    public init(name: String, mainView: ViewAnalyticsModel){
        self.name = name
        self.type = nil
        self.mainView = mainView
    }

    public init(name: String, type: String?, mainView: ViewAnalyticsModel){
        self.name = name
        self.type = type
        self.mainView = mainView
    }

    public func withType(type: String?) -> SecondaryViewAnalyticsModel {
        return SecondaryViewAnalyticsModel(name: name, type: type, mainView: mainView)
    }
    
    public static func == (lhs: SecondaryViewAnalyticsModel, rhs: SecondaryViewAnalyticsModel) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type && lhs.mainView == rhs.mainView
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(mainView)
    }
}


public class ViewAnalyticsModel: ViewAnalyticsModelProtocol, ObservableObject, Hashable, Equatable {
    public let name: String
    public let type: String?
        
    public let funnelStep: AnalyticsViewFunnelStepDetails?
    
    public init(_ name: String){
        self.name = name
        self.type = nil
        self.funnelStep = nil
    }
    
    public init(name: String){
        self.name = name
        self.type = nil
        self.funnelStep = nil
    }
    
    public init(name: String, type: String?){
        self.name = name
        self.type = type
        self.funnelStep = nil
    }
            
    public init(name: String, type: String?, funnelStep: AnalyticsViewFunnelStepDetails?){
        self.name = name
        self.type = type
        self.funnelStep = funnelStep
    }

    public func withType(type: String?) -> ViewAnalyticsModel {
        return ViewAnalyticsModel(name: name, type: type)
    }
    
    public static func == (lhs: ViewAnalyticsModel, rhs: ViewAnalyticsModel) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type && lhs.funnelStep == rhs.funnelStep
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
        hasher.combine(funnelStep)
    }
}

public class AnalyticsViewFunnelStepDetails: Hashable, Equatable {
    
    
    public let funnelName: String
    public let step: Int
    public let isOptionalStep: Bool
    public let isFinalStep: Bool
    
    public init(funnelName: String, step: Int, isOptionalStep: Bool, isFinalStep: Bool) {
        self.funnelName = funnelName
        self.step = step
        self.isOptionalStep = isOptionalStep
        self.isFinalStep = isFinalStep
    }
     
    
    public static func == (lhs: AnalyticsViewFunnelStepDetails, rhs: AnalyticsViewFunnelStepDetails) -> Bool {
        return lhs.funnelName == rhs.funnelName && lhs.step == rhs.step && lhs.isOptionalStep == rhs.isOptionalStep && lhs.isFinalStep == rhs.isFinalStep
    }
 
    public func hash(into hasher: inout Hasher) {
        hasher.combine(funnelName)
        hasher.combine(step)
        hasher.combine(isFinalStep)
        hasher.combine(isFinalStep)
    }
}
