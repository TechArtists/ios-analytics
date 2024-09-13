//  ContactImageView.swift
//  Created by Adi on 11/17/22
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
//
import SwiftUI
import Contacts

struct ContactImageView: View {
    let contact: CNContact
    let textPadding: CGFloat
    
    var body: some View {
        if contact.imageDataAvailable,
           let imageData = contact.imageData {
            Image(uiImage: UIImage(data: imageData)!)
                .resizable()
        } else {
            let givenNameFirstLetter = contact.givenName.prefix(1)
            let lastNameFirstLetter = contact.familyName.prefix(1)
            
            let initials = "\(givenNameFirstLetter.capitalized)\(lastNameFirstLetter.capitalized)"
            
            GeometryReader { g in
                ZStack {
                    randomColor(for: initials)
                    Text(initials)
                        .foregroundColor(Color.black)
                        .font(.system(size: g.size.width * 0.8))
                        .modifier(FitToWidth())
                        .padding(textPadding)
                }
            }
        }
    }
    
    func randomColor(for string: String) -> Color {
        let colors = [
            Color(hex:"#fe4a49"),
            Color(hex:"#2ab7ca"),
            Color(hex:"#fed766"),
            Color(hex:"#e6e6ea"),
            Color(hex:"#f4b6c2"),
            Color(hex:"#6497b1"),
            Color(hex:"#63ace5"),
            Color(hex:"#fe9c8f"),
        ]
        var sum = 0
        for scalar in string.unicodeScalars{
            sum += Int(scalar.value)
        }
        
        let index = sum % colors.count
        
        return colors[index]
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct FitToWidth: ViewModifier {
    var fraction: CGFloat = 1.0
    func body(content: Content) -> some View {
        GeometryReader { g in
            VStack {
                Spacer()
                content
                    .font(.system(size: 1000))
                    .minimumScaleFactor(0.005)
                    .lineLimit(1)
                    .frame(width: g.size.width * self.fraction)
                Spacer()
            }
        }
    }
}

