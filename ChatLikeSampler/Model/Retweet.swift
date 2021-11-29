//
//  Retweet.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/22.
//

import Foundation
import Firebase

class Retweet {
    let profile_icon: String
    let email: String
    let username: String
    let abount: String
    let created_at: Timestamp
    let updated_at: Timestamp
    
    var documentId: String?
    
    init(data: [String: Any]) {
        self.profile_icon = data["profile_icon"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.abount = data["abount"] as? String ?? ""
        self.created_at = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at = data["updated_at"] as? Timestamp ?? Timestamp()
    }
}
