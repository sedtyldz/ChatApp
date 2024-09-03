//
//  ChatAppApp.swift
//  ChatApp
//
//  Created by Sedat Yıldız on 3.09.2024.
//

import SwiftUI
import Firebase

@main
struct ChatAppApp: App {
    init() {
             FirebaseApp.configure()
         }
    var body: some Scene {
        WindowGroup {
            MainPage()
        }
    }
}
