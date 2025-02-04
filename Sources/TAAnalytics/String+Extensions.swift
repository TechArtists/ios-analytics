//  String+Extensions.swift
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
import OSLog

extension String {

    /// Same as `String(describing:)` but without the `Optional()` part printing
    /// It will be `"nil"` when nil.
    init(describingOptional optional: Any?) {
        switch optional {
        case .none:
            self.init("nil")
        case let .some(value):
            self.init(describing: value)
        }
    }
    
    /// - Parameters:
    ///   - length: the length it needs to be trimmed to
    ///   - debugType: what to write in the error log if it's being trimmed
    internal func ta_trim(toLength length: Int, debugType: String) -> String {
        if self.count > length {
            let trimmedString = String(self.prefix(length))
            TALogger.log("Trimming \(debugType) to length \(length) ('\(self)' -> '\(trimmedString)')", level: .error)
            return trimmedString
        }
        return self
    }
    
}
