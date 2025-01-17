//  LoginView.swift
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
//dsf//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
import SwiftUI
import UIKit
import TAAnalytics

struct CreateAccountView: View {
    @EnvironmentObject var analytics: TAAnalytics
    
    @Binding var needsToSignIn: Bool
    @State var username = ""
    @State var showInvalidUsername = false
    @State var password = ""
    
    var body: some View {
        VStack() {
            Text("Create An Account")
                .font(.largeTitle).foregroundColor(Color.white)
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
            
            VStack(alignment: .leading, spacing: 15) {
                TextField("User", text: self.$username)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color.black)
                    .cornerRadius(20.0)
                    .textInputAutocapitalization(.never)
                    .shadow(radius: 10.0, x: 20, y: 10)
                    .onChange(of: self.username) { newValue in
                        if (1...5).contains(self.username.count){
                            showInvalidUsername = true
                        } else {
                            showInvalidUsername = false
                        }
                        analytics.track(event: .UI_BUTTON_TAP)
                    }
                
                if showInvalidUsername {
                    Text("The username should be at least 5 characters long")
                        .foregroundColor(Color.black)
                        .padding(.leading, 10)
                }
                
                
                SecureField("Password", text: self.$password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
            }.padding([.leading, .trailing], 27.5)
            
            Button(action: {
                self.needsToSignIn = false
            }) {
                Text("Create Account")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.green)
                    .cornerRadius(15.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
            }.padding(.top, 50)
            
            Spacer()
            HStack(spacing: 0) {
                Text("Already have an account? ")
                Button(action: {}) {
                    Text("Sign In")
                        .foregroundColor(.black)
                }
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.blue.opacity(0.6), .blue.opacity(1)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .task {
            guard let eventStream = analytics.config.consumers
                .compactMap({ $0.wrappedValue as? EventEmitterConsumer })
                .first?
                .eventStream else { return }
            
            for await trimmedEvent in eventStream {
                print(trimmedEvent.rawValue)
            }
        }
        
    }
    
}
struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView(needsToSignIn: Binding.constant(true))
    }
}
