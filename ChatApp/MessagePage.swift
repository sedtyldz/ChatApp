import SwiftUI
import Firebase

struct MessagePage: View {
    @AppStorage("Email") var Email: String = ""
    var kisi: String
    @State private var name: String = ""
    @State private var durum: Bool = false
    @State private var surname: String = ""
    @State private var username: String = ""
    @State private var photo: String = ""
    @State private var message: String = ""
    @State private var ID: String = ""
    @State private var messages: [Message] = []

    var body: some View {
        VStack {
            HStack {
                let imageurl = photo
                if imageurl.isEmpty {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .clipShape(Circle())
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                        )
                } else {
                    AsyncImage(url: URL(string: imageurl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 55, height: 55)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 60, height: 60)
                    }
                }
                Spacer()
                    .frame(width: 40)
                VStack {
                    Text(username)
                        .bold()
                        .foregroundStyle(.white)
                    Text("\(name) \(surname)")
                        .foregroundStyle(.white)
                }
                
                Spacer()
            }
            .padding()
            Spacer()
            ScrollViewReader { proxy in
                            ScrollView {
                                ForEach(messages) { message in
                                    if message.sender == Email {
                                        // Sağda göster
                                        HStack {
                                            Spacer()
                                            Text(message.content)
                                                .padding()
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        .id(message.id) // Mesaja benzersiz id ekle
                                    } else {
                                        // Solda göster
                                        HStack {
                                            Text(message.content)
                                                .padding()
                                                .background(Color.gray)
                                                .foregroundColor(.white)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            Spacer()
                                        }
                                        .id(message.id) // Mesaja benzersiz id ekle
                                    }
                                }
                            }
                            .onChange(of: messages) { _ in
                                // Her mesaj güncellemesinde en son mesaja kaydır
                                if let lastMessage = messages.last {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
            
            HStack {
                TextField("Enter a message", text: $message)
                    .bold()
                    .padding()
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50, alignment: .center)
                    .background(.gray)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                Spacer()
                Button(action: {
                    if !durum {
                        send(message: message, email: kisi, ID: ID)
                        message = ""
                        fetchOldMessages(ID: ID)
                        listenForMessages(ID: ID)
                    } else {
                        print("hey")
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .resizable()
                        .foregroundStyle(.blue)
                        .frame(width: 35, height: 35)
                        .padding()
                }
            }
            
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear(perform: {
            fetchUser(email: kisi)
            ID = createID(email1: Email, email2: kisi)
            fetchOldMessages(ID: ID)
            listenForMessages(ID: ID)
            
            check(ID: ID) { exists in
                    if exists {
                        durum = true
                    }
                }
        })
        .preferredColorScheme(.dark)
    }
    
    func fetchOldMessages(ID: String) {
        let db = Firestore.firestore()
        
        db.collection("chat").document(ID).collection("messages").order(by: "time", descending: false).getDocuments { snapshot, error in
            if let error = error {
                print("Eski mesajlar alınırken hata: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("Eski mesajlar bulunamadı.")
                return
            }
            
            // Mesajları Message modeline dönüştür ve messages dizisine ata
            messages = documents.map { document in
                let data = document.data()
                let id = document.documentID
                let sender = data["gonderici"] as? String ?? ""
                let content = data["mesaj"] as? String ?? ""
                let time = data["time"] as? String ?? ""
                return Message(id: id, sender: sender, content: content, time: time)
            }
        }
    }
    
    func listenForMessages(ID: String) {
        let db = Firestore.firestore()
        
        db.collection("chat").document(ID).collection("messages").order(by: "time", descending: false).addSnapshotListener { snapshot, error in
            if let error = error {
                print("Mesajlar alınırken hata: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("Mesajlar bulunamadı.")
                return
            }
            
            // Yeni gelen verilerle mesajları güncelle
            let newMessages = documents.map { document in
                let data = document.data()
                let id = document.documentID
                let sender = data["gonderici"] as? String ?? ""
                let content = data["mesaj"] as? String ?? ""
                let time = data["time"] as? String ?? ""
                return Message(id: id, sender: sender, content: content, time: time)
            }
            
            // Sadece yeni gelen mesajları ekleyerek listeyi güncelle
            if messages != newMessages {
                DispatchQueue.main.async {
                                self.messages = newMessages
                                print("hey ana parça")
                            }
            }
        }
    }

    
    func check(ID: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let query = db.collection("chat").getDocuments { snapshot, error in
            if let error = error {
                print("Users verisi alınırken hata: \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else {
                print("Snapshot verisi alınamadı.")
                return
            }
            for document in snapshot.documents {
                if ID == document.documentID {
                    completion(true)
                    return
                }
            }
            completion(false)
        }
    }
    
    func send(message: String, email: String, ID: String) {
        let time = getCurrentTime()
        
        let messageData: [String: Any] = [
            "alıcı": email,
            "gonderici": Email,
            "mesaj": message,
            "time": time
        ]
        
        let db = Firestore.firestore().collection("chat").document(ID).collection("messages").addDocument(data: messageData) { error in
            if let error = error {
                print("Mesaj gönderme hatası: \(error.localizedDescription)")
            } else {
                print("Mesaj gönderildi")
                // Yeni mesaj gönderildiğinde listeyi güncelle
                fetchOldMessages(ID: ID)
            }
        }
    }
    
    func getCurrentTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = Date()
        return dateFormatter.string(from: currentDate)
    }
    
    func createID(email1: String, email2: String) -> String {
        let docID = (email1 + email2).sorted()
        return String(docID)
    }
    
    func fetchUser(email: String) {
        let db = Firestore.firestore()
        let query = db.collection("users").whereField("Email", isEqualTo: email)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents for email \(Email): \(error.localizedDescription)")
            } else {
                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    print("No user found with email: \(Email)")
                    return
                }
                let data = documents[0].data()
                self.name = data["name"] as? String ?? ""
                self.surname = data["surname"] as? String ?? ""
                self.username = data["username"] as? String ?? ""
                self.photo = data["profileImageUrl"] as? String ?? ""
            }
        }
    }
}

struct MessagePage_Previews: PreviewProvider {
    static var previews: some View {
        MessagePage(kisi: "ExampleUser")
    }
}

