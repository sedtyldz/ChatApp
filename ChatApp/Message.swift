//
//  Message.swift
//  ChatApp
//
//  Created by Sedat Yıldız on 13.09.2024.
//
import Foundation

struct Message: Identifiable, Equatable {
    var id: String
    var sender: String
    var content: String
    var time: String
    
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id &&
               lhs.sender == rhs.sender &&
               lhs.content == rhs.content &&
               lhs.time == rhs.time
    }
}



func createID(email1: String, email2: String) -> String {
    let docID = (email1 + email2).sorted()
    return String(docID)
}
