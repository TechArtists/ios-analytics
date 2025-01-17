//
//  Contacts.swift
//  TAAnalyticsExample
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
import Foundation
import Combine
import Contacts
import TAAnalytics
import SwiftUI

class ContactsPermission: ObservableObject {
    let contactStore = CNContactStore()

    @Published var authorizationStatus: CNAuthorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    @Published var contacts: [CNContact] = []

    func requestAccess(analytics: TAAnalytics) {
        guard authorizationStatus == .notDetermined else { return }
        
        analytics.logPermissionScreenShow(for: "contacts")
        
        self.contactStore.requestAccess(for: .contacts) { _, _ in
            let status = CNContactStore.authorizationStatus(for: .contacts)

            analytics.logPermissionButtonTap(allowed: status == .authorized, permissionType: "contacts")

            if status == .authorized {
                self.fetchContacts()
            }

            DispatchQueue.main.async {
                self.authorizationStatus = status
            }
        }
    }
    
    func fetchContacts() {
        guard authorizationStatus == .authorized else { return }
        
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey,
                    CNContactImageDataKey, CNContactImageDataAvailableKey, CNContactThumbnailImageDataKey,
                    CNContactEmailAddressesKey,
                    CNContactPostalAddressesKey
        ]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        request.sortOrder = .givenName
        
            
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                var contactsArray = [CNContact]()
                try self.contactStore.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                    if (contact.phoneNumbers.first?.value.stringValue) != nil{
                        contactsArray.append(contact)
                    }
                })
                
                
                DispatchQueue.main.async {
                    self.contacts = contactsArray
                    self.objectWillChange.send()
                }
            } catch let error {
                print("Failed to enumerate contact", error)
            }
        }
    }
    
    


}
