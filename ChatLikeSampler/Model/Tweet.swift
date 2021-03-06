//
//  Tweet.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/22.
//

import Foundation
import Firebase

class Tweet: NSObject {
    var text: String?
    var image: String?
    var creator: String?
    var is_deleted: Bool?
    
    var created_at: Timestamp?
    
    var documentId: String?
    var likes: [Like]?
    var retweets: [Retweet]?
    var comments: [Comment]?
    
    init(document: QueryDocumentSnapshot) {
        self.documentId = document.documentID
        let data = document.data()
        self.text = data["text"] as? String ?? ""
        self.image = data["image"] as? String ?? ""
        self.likes = data["likes"] as? [Like] ?? [Like]()
        self.retweets = data["retweets"] as? [Retweet] ?? [Retweet]()
        self.comments = data["comments"] as? [Comment] ?? [Comment]()
        self.creator = data["creator"] as? String ?? ""
        self.is_deleted = data["is_deleted"] as? Bool ?? false
        self.created_at = data["created_at"] as? Timestamp ?? Timestamp()
    }
}
