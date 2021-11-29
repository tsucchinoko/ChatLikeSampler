//
//  Tweet.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/22.
//

import Foundation
import Firebase

class Tweet {
    let text: String
    let image: String
    let likes: [Like]?
    let retweets: [Retweet]?
    let comments: [Comment]?
    let creator: String
    let is_deleted: Bool
    
    let created_at: Timestamp
    
    var documentId: String?
    
    init(data: [String: Any]) {
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
