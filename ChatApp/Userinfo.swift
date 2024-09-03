//
//  Userinfo.swift
//  ChatApp
//
//  Created by Sedat Yıldız on 3.09.2024.
//

import SwiftUI
import PhotosUI
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

struct Userinfo: View {
    @State var name:String = ""
    @State var surname:String = ""
    @State var username:String = ""
    @State var isSaved:Bool = false
    @StateObject  var viewModel = Profile()
    
    
   
    
    
    var body: some View {
        NavigationView{
            VStack{
                
                PhotosPicker(selection: $viewModel.selectedItem ) {
                    if let profileImage = viewModel.profileImage{
                        profileImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaledToFill()
                            .frame(width:150,height:150)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                            
                        
                        
                    }else{
                        Image(systemName: "person.circle.fill")
                           .resizable()
                           .aspectRatio(contentMode: .fit)
                           .frame(width:150,height:150)
                           .foregroundColor(Color(.systemGray4))
                           .padding()
                    }
                     
                    
                }
                
              
                Spacer().frame(height:80)
                
                
                TextField("Name", text: $name)
                    .padding()
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.black)
                    .frame(maxWidth:.infinity, maxHeight: 50)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Surname", text: $surname)
                    .padding()
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .textFieldStyle(.roundedBorder)
                
                TextField("Username", text: $username)
                    .padding()
                    .bold()
                    .font(.title2)
                    .foregroundStyle(.brown)
                    .frame(maxWidth:.infinity, maxHeight: 50)
                    .textFieldStyle(.roundedBorder)
                
                Spacer()
                    .frame(height: 50)
                HStack{
                    Button(action: {
                        save(name: name, username: username, surname: surname) { success in
                            if success {
                                print("kayıt oldu")
                                isSaved = true
                            } else {
                                print("olmadı")
                            }
                        }
                    }) {
                        Text("Save My Infos")
                            .padding()
                            .frame(minWidth: 150)
                            .foregroundColor(.white)
                            .font(.title2)
                            .bold()
                            .background(Color.green)
                            .clipShape(.capsule)
                            .padding(.horizontal, 15)
                    }

                  
                }
                NavigationLink(destination: MainPage(), isActive: $isSaved) {
                    EmptyView()
                }
                
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .background(.purple)
            .navigationBarBackButtonHidden(true)
            
         
        }
    }
    func save(name:String,username:String,surname:String,completion: @escaping (Bool) -> Void){
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı ID'si bulunamadı")
                completion(false)
                return
            }
            
        
        
        var UserData = [
            "userId": userId,
            "name" : name,
            "surname" : surname,
            "username" : username
            
        ]
        
        let documentRef =
        Firestore.firestore().collection("users").document(userId).setData(UserData)  { error in
            completion(error == nil)
        }
        
    }
}

#Preview {
    Userinfo()
}

