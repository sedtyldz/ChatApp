//
//  MainPage.swift
//  ChatApp
//
//  Created by Sedat Yıldız on 3.09.2024.
//


import SwiftUI
import Firebase

struct MainPage: View {
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = true
    
    var body: some View {
        NavigationView {
            if isLoggedIn {
                TabView {
                    
                    Person()
                        .tabItem {
                            Image(systemName: "message")
                            Text("Chat")
                        }
                    AddPerson()
                        .tabItem {
                            Image(systemName: "person.badge.plus")
                            Text("New people")
                        }
                    
                    Request()
                        .tabItem {
                            Image(systemName: "heart")
                            Text("Requests")
                        }
                    
                    profilesettings()
                        .tabItem {
                            Image(systemName: "person.circle")
                            Text("Profile")
                        }
                     
                     
                }
                .preferredColorScheme(.light)
                .navigationBarBackButtonHidden(true)
            } else {
                LoginPage()
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    MainPage()
}
