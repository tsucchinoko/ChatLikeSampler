//
//  User.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/05.
//

import Foundation
import Firebase

class User {
    let email: String
    let password: String
    let username: String
    
    init(data: [String: Any]) {
        self.email = data["email"] as? String ?? ""
        self.password = data["password"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
    }
}