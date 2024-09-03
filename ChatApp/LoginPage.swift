//
//   LoginPage.swift
//  ChatApp
//
//  Created by Sedat Yıldız on 3.09.2024.
//

import SwiftUI
import FirebaseAuth

struct LoginPage: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var isLoggedIn: Bool = false
    @State var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Image("welcome")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:150,height:150)
                    .foregroundColor(.purple)
                    .padding()
                
                Spacer().frame(height: 10)
                
                Section(
                    header: Text("ChatAPP  ")
                        .font(.title)
                        .bold()
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)){
                    
                                TextField("E-Mail", text: $email)
                                    .padding()
                                    .font(.title2)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .onChange(of: email) { _ in
                                        errorMessage = ""
                                    }
                           
                            SecureField("Password", text: $password)
                                .padding()
                                .font(.title2)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: password) { _ in
                                    errorMessage = ""
                                }
                            
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .padding()
                            }
                        }
                
                Spacer().frame(height: 30)
                
                HStack {
                    NavigationLink(destination: SignUpPage()) {
                        Text("New User")
                            .padding()
                            .frame(minWidth: 150)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.white)
                            .background(Color.red)
                            .clipShape(.capsule)
                            .padding(.horizontal, 15)
                    }
                    
                    Button(action: {
                        login(email: email, password: password)
                    }, label: {
                        Text("Login")
                            .padding()
                            .frame(minWidth: 150)
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                            .background(Color.green)
                            .clipShape(.capsule)
                            .padding(.horizontal, 15)
                    })
                }
                
                NavigationLink(destination: MainPage(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .background(.cyan)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func login(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = "Error, please check your login information."
            } else {
                isLoggedIn = true
            }
        }
    }
}

#Preview {
    LoginPage()
}

