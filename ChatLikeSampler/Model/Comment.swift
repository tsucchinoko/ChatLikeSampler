//
//  Comment.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/22.
//

import Foundation
import Firebase

class Comment {
    let profile_icon: String
    let email: String
    let username: String
    let text: String
    let is_deleted: Bool
    let created_at: Timestamp
    let updated_at: Timestamp
    
    var documentId: String?
    var likes: [Like]?
    var retweets: [Retweet]?
    var comments: [Comment]?

    
    init(data: [String: Any]) {
        self.profile_icon = data["profile_icon"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.is_deleted = data["is_deleted"] as? Bool ?? false
        self.created_at = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at = data["updated_at"] as? Timestamp ?? Timestamp()
    }
}
