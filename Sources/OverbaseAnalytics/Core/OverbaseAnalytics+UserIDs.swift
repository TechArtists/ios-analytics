//  OverbaseAnalytics+UserIDs.swift
//  Created by Adi on 10/24/22
//
//  Copyright (c) 2022 Overbase SRL (http://overbase.com/)
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

// MARK: -

public protocol OverbaseAnalyticsUserIDsProtocol {
    var userPseudoID: String? { get }
    var userID: String? { get set}
}

// MARK: -

extension OverbaseAnalyticsCompat: OverbaseAnalyticsUserIDsProtocol {
    
    public var userPseudoID: String? {
        if let firstPlf = self.startedPlatforms.filter( { $0 is AnalyticsConsumerWithReadOnlyUserPseudoID } ).first,
           let typeCastedPlf = firstPlf as? AnalyticsConsumerWithReadOnlyUserPseudoID {
            return typeCastedPlf.userPseudoID
        }
        return nil
    }
    
    public var userID: String? {
        get {
            if let firstPlf = self.startedPlatforms.filter( { $0 is AnalyticsConsumerWithReadWriteUserID } ).first,
               let typeCastedPlf = firstPlf as? AnalyticsConsumerWithReadWriteUserID {
                return typeCastedPlf.userID
            }
            return nil
        }
        set {
            self.startedPlatforms
                .filter( { $0 is AnalyticsConsumerWithWriteOnlyUserID } )
                .map( { $0 as! AnalyticsConsumerWithWriteOnlyUserID }  )
                .forEach({ $0.userID = newValue })
        }
    }
    
}
