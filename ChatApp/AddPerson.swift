//
//  AddPerson.swift
//  ChatApp
//
//  Created by Sedat Yıldız on 8.09.2024.
//

import SwiftUI
import Firebase

struct AddPerson: View {
    @ObservedObject var viewModel = UserView() // Kullanıcı verilerini tutan model
    @AppStorage("Email") var Email: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add Your Friends")
                .padding()
                .bold()
                .font(.title)
                .foregroundColor(.black)
            
            List(viewModel.users) { user in // Kullanıcı listesi üzerinde döngü
                VStack(alignment: .leading) {
                    HStack {
                        let imageurl = user.profilePhoto
                        if imageurl.isEmpty {
                            Image(systemName: "person.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 45, height: 45)
                                .clipShape(Circle())
                                .background(
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 50, height: 50)
                                )
                        } else {
                            AsyncImage(url: URL(string: imageurl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            Text("\(user.name) \(user.surname)")
                                .font(.headline)
                                .foregroundColor(.black)
                            Text("@\(user.username)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        
                        Button(action: {
                            addFriend(user: user,email:Email)
                        }) {
                            Text("Add Friend")
                                .foregroundStyle(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .bold()
                                .font(.caption)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.fetchUsers(excludeEmail: Email) // Firestore'dan veri çekiliyor
            }
        }
    }
    
    func addFriend(user: User, email: String) {
        
        let hedef = user.email
        let refere = Firestore.firestore().collection("users")
        
        
        let query = refere.whereField("Email", isEqualTo: hedef)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Dokümanlar alınırken hata oluştu: \(error.localizedDescription)")
            } else {
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    
                    let document = documents[0]
                    let documentID = document.documentID
                    var friendRequest = document.data()["userFriendRequests"] as? [String] ?? []

                    
                    friendRequest.append(email)

                    // diziyi bu şekil güncellemezsen aynı emaili birden fazla kez eklersin
                    refere.document(documentID).updateData([
                        "userFriendRequests": FieldValue.arrayUnion([email])
                    ]) { error in
                        if let error = error {
                            print("Arkadaşlık isteği güncellenirken hata oluştu: \(error.localizedDescription)")
                        } else {
                            print("Arkadaşlık isteği başarıyla gönderildi!")
                        }
                    }
                } else {
                    print("E-posta ile eşleşen bir kullanıcı bulunamadı.")
                }
            }
        }
    }

}


#Preview {
    AddPerson()
}
