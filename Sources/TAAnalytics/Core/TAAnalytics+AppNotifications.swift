//  File.swift
//  Created by Adi on 11/17/22
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
//
import Foundation
import UIKit

extension TAAnalytics {
    
    func addAppLifecycleObservers() {
        
        let obsForeground = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { notification in

            if self.isFirstForeground {
                // ignore increasing the counter for the first one,
                // because the foreground id has already been set to 0 as TAAnalytics was starting up
                self.isFirstForeground = false
            } else {
                self.set(userProperty: .FOREGROUND_ID,
                         to:"\(self.getNextCounterValueFrom(userProperty: .FOREGROUND_ID))")
            }
            
            self.log(event: .APP_FOREGROUND)
        }
        let obsBackground = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { notification in
            
            self.log(event: .APP_BACKGROUND)
        }
        
        notificationCenterObservers.append(obsForeground)
        notificationCenterObservers.append(obsBackground)
    }
    
    
}
