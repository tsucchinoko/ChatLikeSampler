//
//  Message.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/03.
//

import Foundation
import Firebase

class Message {
    let author: String
    let image: String
    let read: Bool
    let text: String
    let created_at: Timestamp
    let updated_at: Timestamp
    
    init(data: [String: Any]) {
        self.author = data["author"] as? String ?? ""
        self.image = data["image"] as? String ?? ""
        self.read = data["read"] as? Bool ?? false
        self.text = data["text"] as? String ?? ""
        self.created_at = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at = data["updated_at"] as? Timestamp ?? Timestamp()
    }
}
