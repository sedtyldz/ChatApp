//
//  SignUpPage.swift
//  ChatApp
//
//  Created by Sedat Yıldız on 3.09.2024.
//

import SwiftUI
import FirebaseAuth
import PhotosUI
import FirebaseFirestore
import FirebaseStorage

struct SignUpPage: View {
    
    @State var email: String = ""
    @State var isSaved:Bool = false
    @State var password: String = ""
    @State var isLoggedIn: Bool = false
    @State var errorMessage: String = ""
    @State var name: String = ""
    @State var surname: String = ""
    @State var username: String = ""
    @StateObject var viewModel = Profile()
    
    var body: some View {
        NavigationView {
            VStack {
                PhotosPicker(selection: $viewModel.selectedItem) {
                    if let profileImage = viewModel.profileImage {
                        profileImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .foregroundColor(Color(.systemGray4))
                            .padding()
                    }
                }
                Spacer().frame(height: 10)
                
                Section(
                    header: Text("  ChatAPP  ")
                        .font(.title)
                        .bold()
                        .foregroundColor(.black)
                        .padding(.bottom, 20)) {
                    
                    TextField("Name", text: $name)
                        .padding()
                        .autocorrectionDisabled(true)
                        .bold()
                        .font(.title2)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Surname", text: $surname)
                        .padding()
                        .autocorrectionDisabled(true)
                        .bold()
                        .font(.title2)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .autocorrectionDisabled(true)
                        .bold()
                        .font(.title2)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("E-Mail:", text: $email)
                        .padding()
                        .autocorrectionDisabled(true)
                        .bold()
                        .font(.title2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .onChange(of: email) { _ in
                            errorMessage = ""
                        }
                    
                    SecureField("Password:", text: $password)
                        .bold()
                        .padding()
                        .font(.title2)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .onChange(of: password) { _ in
                            errorMessage = ""
                        }
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .bold()
                            .italic()
                    }
                }
                
                Spacer().frame(height: 30)
                
                HStack {
                    
                    NavigationLink(destination: LoginPage()) {
                        Text("Login")
                            .padding()
                            .frame(minWidth: 150)
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                            .background(Color.red)
                            .clipShape(.capsule)
                            .padding(.horizontal, 10)
                    }
                 
                    Button(action: {
                        sign(name: name, surname: surname, username: username, email: email, password: password)
                    }, label: {
                        Text("Sign Up")
                            .padding()
                            .frame(minWidth: 150)
                            .foregroundColor(.white)
                            .bold()
                            .font(.title2)
                            .background(Color.green)
                            .clipShape(.capsule)
                            .padding(.horizontal, 10)
                    })
                    
                    NavigationLink(destination: MainPage(), isActive: $isLoggedIn) {
                        EmptyView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.purple)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func check(name: String, surname: String, username: String, email: String, password: String) -> Bool {
        // Boş olup olmadığını kontrol ediyoruz
        if name.isEmpty || surname.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty {
            return false
        }
        return true
    }
    
    
    func save(name:String,username:String,surname:String,email:String,password:String,completion: @escaping (Bool) -> Void){
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı ID'si bulunamadı")
            completion(false)
            return
        }
        
        var UserData = [
            "userId": userId,
            "name" : name,
            "surname" : surname,
            "username" : username,
            "Email":email,
            "Password":password
            
        ]
        
        let documentRef =
        Firestore.firestore().collection("users").document(userId).setData(UserData)  { error in
            completion(error == nil)
        }
    }
    
    
    
    
    func sign(name: String, surname: String, username: String, email: String, password: String) {
        if check(name: name, surname: surname, username: username, email: email, password: password) {
            
            
            // create a user
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = "This email already has an account"
                } else {
                    save(name: name, username: username, surname: surname,email: email,password: password) { success in
                        if success {
                            print("kayıt oldu")
                            isSaved = true
                        } else {
                            print("olmadı")
                        }
                    }
                    
                    
                    isLoggedIn = true
                }
            
           
            }
        } else {
            errorMessage = "Please fill all the information."
        }
    }
}

#Preview {
    SignUpPage()
}

