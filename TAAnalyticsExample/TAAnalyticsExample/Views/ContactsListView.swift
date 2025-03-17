//  ContactsListView.swift
//
//  Created by Adi on 10/25/22.
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
import SwiftUI
import TAAnalytics
import Combine
import Contacts

struct ContactsListView: View {

    @EnvironmentObject var analytics: TAAnalytics
    
    var viewAnalyticsModel: ViewAnalyticsModel {
        switch contactsPermission.authorizationStatus {
            case .notDetermined: return .CONTACTS_PERMISSION_NOT_DETERMINED
            case .authorized: return .CONTACTS_WITH_PERMISSION
            case .denied: return .CONTACTS_PERMISSION_DENIED
            default: return .CONTACTS_PERMISSION_DENIED
        }
    }
    
    @ObservedObject var contactsPermission = ContactsPermission()
    
    var noPermissionHeaderView: some View {
        VStack() {
            Text("TA Analytics Demo App")
                .font(.largeTitle).foregroundColor(Color.black)
                .multilineTextAlignment(.center)
                .padding([.top, .bottom], 40)
                .shadow(radius: 10.0, x: 20, y: 10)
            
            Image(uiImage: UIImage(named:"AppIcon")!)
                .resizable()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 10.0, x: 20, y: 10)
                .padding(.bottom, 50)
        }
    }
    

    var body: some View {
        Group {
            if contactsPermission.authorizationStatus == .notDetermined {
                VStack(alignment: .center,spacing: 20) {
                    noPermissionHeaderView
                    Text("Please allow contacts permission for the app to work 🙏.")
                        .multilineTextAlignment(.center)
                    
                    TAAnalyticsButtonView(
                        analyticsName: "request contacts permission",
                        analyticsView: viewAnalyticsModel,
                        taAnalytics: analytics) {
                            contactsPermission.requestAccess(analytics: analytics)
                        } label: {
                            Text("Request Contact Permission")
                        }
                    Spacer()
                }
            } else if contactsPermission.authorizationStatus == .denied {
                VStack(alignment: .center,spacing: 20) {
                    noPermissionHeaderView
                    Text("Please allow contacts permission from the settings")
                    TAAnalyticsButtonView(
                        analyticsName: "open settings",
                        analyticsView: viewAnalyticsModel,
                        taAnalytics: analytics) {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                        } label: {
                            Text("Open Settings")
                        }
                    Spacer()
                }
            } else {
                VStack(spacing: 20){
                    List {
                        ForEach(self.contactsPermission.contacts, id: \.self.identifier) {
                            contact in
                            NavigationLinkWithTap(
                                tapHandler: {
                                    analytics.track(buttonTap: "contact", onView: viewAnalyticsModel)
                                },
                                destination: ContactDetailView(contact: contact))
                            {
                                ContatsListRowView(contact: contact)
                            }
                        }
                        .backgroundStyle(.white)
                    }
                    .listRowBackground(Color.white)
                    .backgroundStyle(.white)
                }
            }
        }
        .navigationTitle(Text("Contacts"))
        .onAppear() {
            analytics.track(viewShow: viewAnalyticsModel)
            contactsPermission.fetchContacts()
            
            analytics.config.consumers.forEach { consumer in
                print(type(of: consumer))
            }
        }
    }
}
