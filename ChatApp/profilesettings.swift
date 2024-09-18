//
//  profilesettings.swift
//  ChatApp
//
//  Created by Sedat Yıldız on 8.09.2024.
//

import SwiftUI
import Firebase

struct profilesettings: View {

        @AppStorage("Email") var Email: String = ""
        @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
        
        @State private var name: String = ""
        @State private var surname: String = ""
        @State private var username: String = ""
        @State private var image: String = ""
        @AppStorage("bio") var bio: String = "Hey There I am using ChatApp"
        

        var body: some View {
            VStack {
                
                if image != "" {
                    AsyncImage(url: URL(string: image)){ result in
                        
                        result.image?.resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                        
                    }
                }
                else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .foregroundColor(Color(.systemGray4))
                        .padding()
                }
                
                Text("\(name) \(surname)")
                    .bold()
                    .font(.title2)

                
                Spacer()
                    .frame(height: 50)
                
                Form{
                    Section(header: Text("User Infos")){
                        Text("Name:\(name)")
                            .padding()
                            .bold()
                            .foregroundStyle(Color.black)
                            .font(.title2)
                        Text("Surname:\(surname)")
                            .padding()
                            .bold()
                            .foregroundStyle(Color.black)
                            .font(.title2)
                        Text("Username:\(username)")
                            .padding()
                            .bold()
                            .foregroundStyle(Color.black)
                            .font(.title2)
                        Text("Bio:\(bio)")
                            .padding()
                            .bold()
                            .foregroundStyle(Color.black)
                            .font(.title2)
                    }
                    
                    
                    
                    
                    
                    
                }
                HStack{
                    
                    
                    NavigationLink(destination: ChangeinfoPage(name:$name, surname:$surname, username: $username)){
                        Text("Edit Profile")
                            .padding()
                            .frame(minWidth: 150)
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                            .background(Color.blue)
                            .clipShape(.capsule)
                            .padding(.horizontal, 10)
                    }
                    
                    Button(action: {
                        isLoggedIn = false
                        bio = "Hey There I am using ChatApp"
                        Email = ""
                        
                    }) {
                        Text("Log Out")
                            .padding()
                            .frame(minWidth: 150)
                            .foregroundStyle(.white)
                            .bold()
                            .font(.title2)
                            .background(Color.red)
                            .clipShape(.capsule)
                            .padding(.horizontal, 10)
                    }
                }
                
                NavigationLink(destination: LoginPage(), isActive: Binding(
                    get: { !isLoggedIn },
                    set: { _ in }
                )) {
                    EmptyView()
                }
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    getUserInfo(email: Email)
                }
            }
        }
        
        
        
        func getUserInfo(email: String) {
            let refere = Firestore.firestore().collection("users")
            let query = refere.whereField("Email", isEqualTo: email)
            
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Dokümanlar alınırken hata oluştu: \(error.localizedDescription)")
                } else {
                    if let documents = querySnapshot?.documents, !documents.isEmpty {
                        let data = documents[0].data()
                        
                        // State değişkenlerine atama
                        DispatchQueue.main.async {
                            name = data["name"] as? String ?? "No Name"
                            surname = data["surname"] as? String ?? "No Surname"
                            username = data["username"] as? String ?? "No Username"
                            image = data["profileImageUrl"] as? String ?? ""
                        }
                        
                        print("Name: \(name), Surname: \(surname), Username: \(username)")
                    } else {
                        print("E-posta ile eşleşen bir kullanıcı bulunamadı.")
                    }
                }
            }
        }

    }


#Preview {
    profilesettings()
}
