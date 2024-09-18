import SwiftUI
import Firebase

struct ChangeinfoPage: View {
    @Binding var name: String
    @Binding var surname: String
    @Binding var username: String
    @AppStorage("bio") var bio: String = "Hey There I am using ChatApp"

    @State private var showToast: Bool = false
    @AppStorage("Email") var Email: String = ""
    
    var body: some View {
        VStack {
            Text("Edit Profile")
                .bold()
                .font(.callout)
                .foregroundColor(.black)
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Surname", text: $surname)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Bio", text: $bio)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Spacer()
            
            Button(action: {
                // Kaydetme işlemi ve toast mesajını gösterme
                change(name: name, surname: surname, username: username, email: Email, bio: bio)
                
                withAnimation { showToast = true }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    withAnimation { showToast = false }
                }
            }) {
                Text("Save")
                    .padding()
                    .frame(minWidth: 150)
                    .foregroundStyle(.white)
                    .bold()
                    .font(.title2)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .padding(.horizontal, 10)
            }
            
            if showToast {
                VStack {
                    Spacer().frame(height: 50)
                    
                    Text("Infos Saved")
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut)
                }
            }
        }
    }
    
    func change(name: String, surname: String, username: String, email: String, bio: String) {
        let fr = Firestore.firestore().collection("users")
        
        // Email alanına göre belgeyi bul
        let son = fr.whereField("Email", isEqualTo: email)
        
        
        son.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Dokümanlar alınırken hata oluştu: \(error.localizedDescription)")
            } else {
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    let document = documents[0]  // İlk eşleşen dokümanı al
                    
                    let documentID = document.documentID  // Belge kimliğini al
                    
                    
                    // Yeni verilerle güncelleme işlemi yap
                    let dataToUpdate: [String: Any] = [
                        "name": name,
                        "surname": surname,
                        "username": username,
                        "Bio": bio  // Bio da güncelleniyor
                    ]
                    
                    
                    fr.document(documentID).updateData(dataToUpdate) { error in
                        if let error = error {
                            print("Veri güncellenirken hata oluştu: \(error.localizedDescription)")
                        } else {
                            print("Veri başarıyla güncellendi!")
                        }
                    }
                } else {
                    print("Belge bulunamadı.")
                }
            }
        }
    }
}

struct ChangeinfoPage_Previews: PreviewProvider {
    @State static var previewName = "sedat"
    @State static var previewSurname = "yıldız"
    @State static var previewUsername = "salaksherlock"
    @State static var previewBio = "deneme"
    
    static var previews: some View {
        ChangeinfoPage(name: $previewName, surname: $previewSurname, username: $previewUsername)
    }
}

