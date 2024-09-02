//  NavigationLinkWithTap.swift
//  Created by Adi on 10/26/22.
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
//
import Foundation
import SwiftUI

struct NavigationLinkWithTap<Label, Destination> : View where Label : View, Destination : View {
    
    @State private var isSelected: Bool = false
    
    let tapHandler: () -> ()
    let destination : Destination
    let label: () -> Label
    
    init(tapHandler: @escaping () -> (), destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        self.tapHandler = tapHandler
        self.destination = destination
        self.label = label
    }
                  
    var body: some View {
        NavigationLink(destination: destination,
                       isActive: $isSelected,
                       label: label)
        .onChange(of: isSelected) { newValue in
            tapHandler()
        }
    }
                  
}
