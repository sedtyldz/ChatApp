//
//  Request.swift
//  ChatApp
//
//  Created by Sedat Yıldız on 8.09.2024.
//

import SwiftUI
import Firebase

struct Request: View {
    @AppStorage("Email") var Email: String = ""
    @State var friendrequest: [String] = []
    @State private var users: [User] = []
    @State var friendList: [String] = []
    @State private var friends: [User] = []

    var body: some View {
        VStack {
            // Friend Requests Section
            Section {
                ScrollView {
                    VStack {
                        Text("Friend Requests")
                            .bold()
                            .font(.title)
                            .padding()
                            .foregroundColor(.blue)
                        if users.isEmpty{
                            Text("There Is No New Friend Request")
                                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                                .bold()
                                .padding()
                                
                        }
                        else{
                            
                            ForEach(users) { user in
                                VStack {
                                    HStack {
                                        let imageurl = user.profilePhoto
                                        if imageurl.isEmpty {
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 55, height: 55)
                                                .clipShape(Circle())
                                                .background(
                                                    Circle()
                                                        .fill(Color.gray.opacity(0.3))
                                                        .frame(width: 70, height: 70)
                                                )
                                        } else {
                                            AsyncImage(url: URL(string: imageurl)) { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 70, height: 70)
                                                    .clipShape(Circle())
                                            } placeholder: {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 50, height: 50)
                                            }
                                        }
                                        Spacer()
                                            .frame(width: 40)
                                        VStack {
                                            Text(user.username)
                                                .bold()
                                            Text("\(user.name) \(user.surname)")
                                        }
                                        Spacer()
                                        Button(action: {
                                            addfriend(email: user.email)
                                        }) {
                                            Text("Accept")
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical)
                                                .background(Color.blue)
                                                .cornerRadius(10)
                                                .bold()
                                                .font(.caption)
                                        }
                                        Button(action: {
                                            print("Decline request")
                                        }) {
                                            Text("Decline")
                                                .foregroundStyle(.white)
                                                .padding(.horizontal, 10)
                                                .padding(.vertical)
                                                .background(Color.gray)
                                                .cornerRadius(10)
                                                .bold()
                                                .font(.caption)
                                        }
                                    }
                                    .padding(20)
                                }
                                Spacer()
                            }
                        }
                    }
                    .onAppear {
                        getuserrequestlist(Email: Email)
                        getuserFriendList(Email: Email)
                    }
                }
            }

            // Friend List Section
            Section {
                ScrollView {
                    VStack {
                        Text("Friend List")
                            .bold()
                            .font(.title)
                            .padding()

                        ForEach(friends) { friend in
                            VStack {
                                HStack {
                                    let imageurl = friend.profilePhoto
                                    if imageurl.isEmpty {
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 55, height: 55)
                                            .clipShape(Circle())
                                            .background(
                                                Circle()
                                                    .fill(Color.gray.opacity(0.3))
                                                    .frame(width: 70, height: 70)
                                            )
                                    } else {
                                        AsyncImage(url: URL(string: imageurl)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 70, height: 70)
                                                .clipShape(Circle())
                                        } placeholder: {
                                            Circle()
                                                .fill(Color.gray.opacity(0.3))
                                                .frame(width: 50, height: 50)
                                        }
                                    }
                                    Spacer()
                                        .frame(width: 40)
                                    VStack(alignment: .leading) {
                                        Text(friend.username)
                                            .bold()
                                        Text("\(friend.name) \(friend.surname)")
                                    }
                                    Spacer()
                                    Button(action: {
                                        removefriend(email:friend.email)
                                    }) {
                                        Text("Remove")
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical)
                                            .background(Color.gray)
                                            .cornerRadius(10)
                                            .bold()
                                            .font(.caption)
                                    }
                                }
                                .padding(20)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func removefriend(email:String){
        let db = Firestore.firestore()
        let query = db.collection("users").whereField("Email", isEqualTo: Email)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents for email \(Email): \(error.localizedDescription)")
            } else {
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No user found with email: \(Email)")
                    return
                }
                let document = documents.first
                let id:String = document!.documentID
                let userRef = db.collection("users").document(id)
                userRef.updateData([
                    "userFriendList" : FieldValue.arrayRemove([email])]){
                        error in
                        if let error = error {
                                       print("Error updating user friend list: \(error.localizedDescription)")
                                   } else {
                                       print("Friend added successfully")
                                   }
                    }
                
                
                
                
            }
        }
        let remove = db.collection("users").whereField("Email", isEqualTo: email)
        remove.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents for email \(email): \(error.localizedDescription)")
            } else {
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No user found with email: \(email)")
                    return
                }
                let document = documents.first
                let id:String = document!.documentID
                let userRef = db.collection("users").document(id)
                userRef.updateData([
                    "userFriendList" : FieldValue.arrayRemove([Email])]){
                        error in
                        if let error = error {
                                       print("Error updating user friend list: \(error.localizedDescription)")
                                   } else {
                                       print("Friend added successfully")
                                   }
                    }
                
                
                
                
            }
        }
    }
        
    
    
    func addfriend(email:String){
        let db = Firestore.firestore()
        let query = db.collection("users").whereField("Email", isEqualTo: Email)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents for email \(Email): \(error.localizedDescription)")
            } else {
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No user found with email: \(Email)")
                    return
                }
                let document = documents.first
                let id:String = document!.documentID
                let userRef = db.collection("users").document(id)
                
                userRef.updateData([
                    "userFriendRequests" : FieldValue.arrayRemove([email])]){
                        error in
                        if let error = error {
                                       print("Error updating user friend list: \(error.localizedDescription)")
                                   } else {
                                       print("Friend added successfully")
                                   }
                    }
                userRef.updateData([
                    "userFriendList" : FieldValue.arrayUnion([email])]){
                        error in
                        if let error = error {
                                       print("Error updating user friend list: \(error.localizedDescription)")
                                   } else {
                                       print("Friend added successfully")
                                   }
                    }
                
                
                
                
            }
        }
        let add = db.collection("users").whereField("Email",isEqualTo: email)
        add.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents for email \(email): \(error.localizedDescription)")
            } else {
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No user found with email: \(email)")
                    return
                }
                let document = documents.first
                let id:String = document!.documentID
                let userRef = db.collection("users").document(id)
                
                // sended  ?
                
                /*
                userRef.updateData([
                    "userFriendRequests" : FieldValue.arrayRemove([email])]){
                        error in
                        if let error = error {
                                       print("Error updating user friend list: \(error.localizedDescription)")
                                   } else {
                                       print("Friend added successfully")
                                   }
                    }
                 */
                userRef.updateData([
                    "userFriendList" : FieldValue.arrayUnion([Email])]){
                        error in
                        if let error = error {
                                       print("Error updating user friend list: \(error.localizedDescription)")
                                   } else {
                                       print("Friend added successfully")
                                   }
                    }
                
                
                
                
            }
        }
    }

    // Fetch friend requests
    func getuserrequestlist(Email: String) {
        self.users.removeAll()
        let db = Firestore.firestore()
        let query = db.collection("users").whereField("Email", isEqualTo: Email)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents for email \(Email): \(error.localizedDescription)")
            } else {
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No user found with email: \(Email)")
                    return
                }
                let data = documents[0].data()
                DispatchQueue.main.async {
                    friendrequest = data["userFriendRequests"] as? [String] ?? []
                    print(friendrequest)
                    getuserinfosbyemail()
                }
            }
        }
    }

    // Fetch user info for friend requests
    func getuserinfosbyemail() {
        let rf = Firestore.firestore().collection("users")
        for item in friendrequest {
            let query = rf.whereField("Email", isEqualTo: item)
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents for friend requests: \(error.localizedDescription)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let username = data["username"] as? String,
                           let name = data["name"] as? String,
                           let surname = data["surname"] as? String,
                           let profilePhoto = data["profileImageUrl"] as? String,
                           let email = data["Email"] as? String {
                            
                            let newUser = User(id: document.documentID, username: username, name: name, surname: surname, profilePhoto: profilePhoto, email: email)
                            DispatchQueue.main.async {
                                self.users.append(newUser)
                                print(users)
                            }
                        }
                    }
                }
            }
        }
    }

    // Fetch friend list
    func getuserFriendList(Email: String) {
        self.friends.removeAll()
        let db = Firestore.firestore()
        let query = db.collection("users").whereField("Email", isEqualTo: Email)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents for email \(Email): \(error.localizedDescription)")
            } else {
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No user found with email: \(Email)")
                    return
                }
                let data = documents[0].data()
                DispatchQueue.main.async {
                    friendList = data["userFriendList"] as? [String] ?? []
                    print(friendList)
                    getuserinfofriends()
                }
            }
        }
    }

    // Fetch user info for friends
    func getuserinfofriends() {
        let rf = Firestore.firestore().collection("users")
        for item in friendList {
            let query = rf.whereField("Email", isEqualTo: item)
            query.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents for friend list: \(error.localizedDescription)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let username = data["username"] as? String,
                           let name = data["name"] as? String,
                           let surname = data["surname"] as? String,
                           let profilePhoto = data["profileImageUrl"] as? String,
                           let email = data["Email"] as? String {
                            
                            let newUser = User(id: document.documentID, username: username, name: name, surname: surname, profilePhoto: profilePhoto, email: email)
                            DispatchQueue.main.async {
                                self.friends.append(newUser)
                                print(friends)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    Request()
}


