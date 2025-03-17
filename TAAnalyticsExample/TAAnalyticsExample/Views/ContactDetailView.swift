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

//  ContactDetailView.swift
//  Created by Adi on 10/26/22.
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
import Foundation
import Contacts
import SwiftUI
import TAAnalytics

struct ContactDetailView: View {

    @EnvironmentObject var analytics: TAAnalytics

    private var analyticsView: ViewAnalyticsModel { .CONTACT.withType(type: contact.identifier) }
    
    let contact: CNContact
    
    init(contact: CNContact) {
        self.contact = contact
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 20) {
                ContactImageView(contact: contact, textPadding: 20)
                    .clipShape(Circle())
                    .frame(width: 150, height: 150)
                    .clipped()
                HStack {
                    Text("\(contact.givenName) \(contact.familyName)")
                        .font(.largeTitle)
                }
                
                if let email = contact.emailAddresses.first?.value as? String {
                    HStack(spacing:10) {
                        Text("Email:")
                        Spacer()
                        Text(email)
                    }.padding(.bottom, 5)
                }
                if let address = contact.postalAddresses.first?.value {
                    HStack(spacing:10) {
                        Text("Address:")
                        Spacer()
                        Text("\(address.street), \(address.city), \(address.country)").multilineTextAlignment(.trailing)
                    }.padding(.bottom, 5)
                }
                callButton(label: "Main Number", phoneNumber: contact.phoneNumbers.first?.value.stringValue ?? "123456789")
                callButton(label: "Outdated Number", phoneNumber: "123")
            }
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
        }.onAppear() {
            analytics.track(viewShow: analyticsView)
        }
    }
    
    func callButton(label: String, phoneNumber: String) -> some View {
        return HStack(spacing: 10){
            Text("\(label.capitalized):")
            Spacer()
            TAAnalyticsButtonView(
                analyticsName: "call",
                analyticsView: analyticsView,
                taAnalytics: analytics
            ) { 
                MyCallManager(analytics: analytics).callIfAtLeastFourDigits(phoneNumber: phoneNumber)
            } label: {
                Text(phoneNumber)
            }
        }
    }
}
