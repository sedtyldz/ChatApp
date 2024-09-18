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
    
    // variables
    @State var email: String = ""
    @State var isSaved: Bool = false
    @State var password: String = ""
    @State var errorMessage: String = ""
    @State var name: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @AppStorage("Email") var Email:String = ""
    @AppStorage("friendcount") var friendcount = 0
    @AppStorage("bio") var bio: String = "Hey There I am using ChatApp"
    @State var surname: String = ""
    @State var username: String = ""
    @StateObject var viewModel = Profile()
    
    
    
    var body: some View {
        NavigationView {
            VStack {
                // get profile picture from user
                PhotosPicker(selection: $viewModel.selectedItem) {
                    if let profileImage = viewModel.profileImage {
                        Image(uiImage: profileImage)
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
                
                Section(header: Text("  ChatAPP  ")
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
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: email) { _ in
                            errorMessage = ""
                        }
                    
                    SecureField("Password:", text: $password)
                        .padding()
                        .autocorrectionDisabled(true)
                        .bold()
                        .font(.title2)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .textFieldStyle(.roundedBorder)
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
                
                //butons
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
                        // Profile image parametresiyle sign fonksiyonu çağrıldı
                        sign(name: name, surname: surname, username: username, email: email, password: password, profileImage: viewModel.profileImage)
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
        .preferredColorScheme(.light)
        .navigationBarBackButtonHidden(true)
    }
    
    // Fonksiyonlar
    
    // resmi firebase storage koyan fonksiyon
    func upload(image: UIImage, completion: @escaping (String?) -> Void) {
        
        let reference = Storage.storage().reference()
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                print("Error converting image to data")
                completion(nil)
                return
            }
        
        let imageID = UUID().uuidString
        let imageRef = reference.child("images/\(imageID).jpg")
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("Error retrieving download URL: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                completion(url?.absoluteString)
            }
        }
    }
    
    
    // verileri firestore kayıt eden fonksiyon
    func save(name: String, username: String, surname: String, email: String, password: String, profileImageUrl: String?, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı ID'si bulunamadı")
            completion(false)
            return
        }
        
        
        
        var userData: [String: Any] = [
            "userId": userId,
            "name": name,
            "surname": surname,
            "username": username,
            "Email": email,
            "Password": password,
            "Bio":bio,
            "friendscount":friendcount,
            "userFriendList":[],
            "userFriendRequests":[],
            "userFriendSent":[]
         
        ]
        
        if let profileImageUrl = profileImageUrl {
            userData["profileImageUrl"] = profileImageUrl
        }
        
        Firestore.firestore().collection("users").document(userId).setData(userData) { error in
            completion(error == nil)
        }
    }
    
    
    // giriş bilgilerini ve diğer fonksiyonları içerisinde barındıran ana fonksiyon
    func sign(name: String, surname: String, username: String, email: String, password: String, profileImage: UIImage?) {
        if check(name: name, surname: surname, username: username, email: email, password: password) {
            
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = "This email already has an account"
                } else {
                    
                    if let profileImage = profileImage {
                        upload(image: profileImage) { url in
                            save(name: name, username: username, surname: surname, email: email, password: password, profileImageUrl: url) { success in
                                if success {
                                    print("kayıt oldu")
                                    isLoggedIn = true
                                    isSaved = true
                                    Email = email
                                } else {
                                    print("olmadı")
                                }
                            }
                        }
                    } else {
                        save(name: name, username: username, surname: surname, email: email, password: password, profileImageUrl: nil) { success in
                            if success {
                                print("kayıt oldu")
                                isLoggedIn = true
                                Email = email
                                
                            } else {
                                print("olmadı")
                            }
                        }
                    }
                    
                    isLoggedIn = true
                }
            }
        } else {
            errorMessage = "Please fill all the information."
        }
    }
    
    // boş bilgi olup olmadığını kontrol eden fonksiyon
    func check(name: String, surname: String, username: String, email: String, password: String) -> Bool {
        // Boş olup olmadığını kontrol ediyoruz
        if name.isEmpty || surname.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty {
            return false
        }
        return true
    }
}

#Preview {
    SignUpPage()
}
