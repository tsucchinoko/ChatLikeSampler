//
//  Room.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/03.
//

import Foundation
import Firebase

class Room {
    let name: String
    let messages: Message?
    let creator: String
    let created_at: Timestamp
    let updated_at: Timestamp
    
    init(data: [String: Any]) {
        self.name = data["name"] as? String ?? ""
        self.messages = data["messages"] as? Message
        self.creator = data["creator"] as? String ?? ""
        self.created_at = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at = data["updated_at"] as? Timestamp ?? Timestamp()
    }
}
