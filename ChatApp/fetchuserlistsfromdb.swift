import Foundation
import Firebase

struct User: Identifiable {
    var id: String
    var username: String
    var name: String
    var surname: String
    var profilePhoto: String
    var email: String
}

class UserView: ObservableObject {
    @Published var users = [User]()
    private var db = Firestore.firestore()
    
    func fetchUsers(excludeEmail: String) {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Users verisi alınırken hata: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot verisi alınamadı.")
                return
            }
            
            // Doküman verilerini kontrol etme
            print("Doküman sayısı: \(snapshot.documents.count)")
            
            self.users = snapshot.documents.compactMap { doc in
                let data = doc.data()
                
                // Verileri kontrol etme
                print("Veri: \(data)")
                
                let id = doc.documentID
                let name = data["name"] as? String ?? ""
                let surname = data["surname"] as? String ?? ""
                let username = data["username"] as? String ?? ""
                let profilePhoto = data["profileImageUrl"] as? String ?? ""
                let userEmail = data["Email"] as? String ?? ""

                // E-posta eşleşiyorsa bu kullanıcıyı atla
                print("\(userEmail), \(excludeEmail)\n")

                if userEmail == excludeEmail {
                    print("Hariç tutulan kullanıcı: \(userEmail)")
                    return nil
                }
                else{
                    
                    // Geri kalan kullanıcıları e-posta ile birlikte döndür
                    return User(id: id, username: username, name: name, surname: surname, profilePhoto: profilePhoto, email: userEmail)
                }
            }
            
            // Sonuçları kontrol etme
            print("Kullanıcı sayısı: \(self.users.count)")
        }
    }
}

