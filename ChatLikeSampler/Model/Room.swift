//
//  Room.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/03.
//

import Foundation
import Firebase

class Room: Equatable {
    static func == (lhs: Room, rhs: Room) -> Bool {
        return lhs.roomId == rhs.roomId
    }
    
    let name: String
    let members: [String]
    let messages: Message?
    let creator: String
    let created_at: Timestamp
    let updated_at: Timestamp
    
    var partnerUser: User?
    var roomId: String?
    var latestMessage: Message?
    let latestMessageId: String
    var unreadCount  =  0
        
    init(document: QueryDocumentSnapshot) {
        self.roomId = document.documentID
        let data = document.data()
        self.name = data["name"] as? String ?? ""
        self.members = data["members"] as? [String] ?? [String]()
        self.messages = data["messages"] as? Message
        self.creator = data["creator"] as? String ?? ""
        self.created_at = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at = data["updated_at"] as? Timestamp ?? Timestamp()
        self.latestMessageId = data["latestMessageId"] as? String ?? ""
    }
}
