//
//  Comment.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/22.
//

import Foundation
import Firebase

class Comment: NSObject {
    var profile_icon: String?
    var email: String?
    var username: String?
    var text: String?
    var is_deleted: Bool?
    var created_at: Timestamp?
    var updated_at: Timestamp?
    
    var documentId: String?
    var likes: [Like]?
    var retweets: [Retweet]?
    var comments: [Comment]?

    
    init(document: QueryDocumentSnapshot) {
        self.documentId = document.documentID
        let data = document.data()
        self.profile_icon = data["profile_icon"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        self.is_deleted = data["is_deleted"] as? Bool ?? false
        self.created_at = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at = data["updated_at"] as? Timestamp ?? Timestamp()
        self.likes = data["likes"] as? [Like] ?? [Like]()
        self.retweets = data["retweets"] as? [Retweet] ?? [Retweet]()
        self.comments = data["comments"] as? [Comment] ?? [Comment]()
    }
}
