import SwiftUI
import Firebase

struct Person: View {
    
    @State var istek = "kisi"
    @AppStorage("Email") var Email: String = ""
    @AppStorage("tick") var tick: Bool = false
    @State private var friends: [User] = []
    @State var friendList: [String] = []
    var body: some View {
        NavigationView{
            
            ScrollView {
                VStack {
                    Text("Chat with your friends")
                        .bold()
                        .font(.title)
                        .padding()

                    ForEach(friends) { friend in
                        NavigationLink(destination: MessagePage(kisi:friend.email)){
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
                                            .frame(width: 65, height: 65)
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
                                    Spacer()
                                        .frame(height:10)
                                }
                                Spacer()
                                
                            }
                            .padding(10)
                        }
                    }
                    }
                }
                .onAppear(){
                    getuserFriendList(Email: Email)
                }
            }
        }
    }
    
    
    // get friends of user
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
                    getuserinfofriends()
                    
                    
                }
            }
        }
    }
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
    Person()
}
