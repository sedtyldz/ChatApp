//
//  Profile.swift
//  ChatApp
//
//  Created by Sedat Yıldız on 3.09.2024.
//

import SwiftUI
import PhotosUI


class Profile: ObservableObject {
    @Published var selectedItem: PhotosPickerItem? {
        didSet { Task { try? await loadImage() } }
    }
    
    @Published var profileImage: UIImage?
    
    func loadImage() async throws {
        guard let item = selectedItem else { return }
        // Resmi Data olarak yükleyin
        guard let imageData = try await item.loadTransferable(type: Data.self) else { return }
        // Data'dan UIImage oluşturun
        guard let uiImage = UIImage(data: imageData) else { return }
        // UIImage'ı ayarlayın
        self.profileImage = uiImage
    }
}


