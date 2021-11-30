//
//  Like.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/22.
//

import Foundation
import Firebase

class Like: NSObject {
    var profile_icon: String?
    var email: String?
    var username: String?
    var abount: String?
    var created_at: Timestamp?
    var updated_at: Timestamp?
    
    var documentId: String?
    
    init(document: QueryDocumentSnapshot) {
        self.documentId = document.documentID
        let data = document.data()
        self.profile_icon = data["profile_icon"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.abount = data["abount"] as? String ?? ""
        self.created_at = data["created_at"] as? Timestamp ?? Timestamp()
        self.updated_at = data["updated_at"] as? Timestamp ?? Timestamp()
    }
}
