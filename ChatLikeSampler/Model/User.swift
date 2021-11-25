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
    let university_name: String
    let undergraduate_and_department: String
    let graduation_year: String
    let about: String
    let desired_industry: [String]
    let desired_occupation: [String]
    let desired_job_area: [String]
    let student_card: String
    let id_card: String
    let profile_icon: String
    let header_img: String
    let is_activated: Bool
    let is_deleted: Bool
    let is_follow_notification: Bool
    let is_comment_notification: Bool
    let is_message_notification: Bool
    let is_retweet_notification: Bool
    let logined_at: Timestamp
    
    var uid: String?
    
    init(data: [String: Any]) {
        self.email = data["email"] as? String ?? ""
        self.password = data["password"] as? String ?? ""
        self.username = data["username"] as? String ?? ""
        self.university_name = data["university_name"] as? String ?? ""
        self.undergraduate_and_department = data["undergraduate_and_department"] as? String ?? ""
        self.graduation_year = data["graduation_year"] as? String ?? ""
        self.about = data["about"] as? String ?? ""
        self.desired_industry = data["desired_industry"] as? [String] ?? [String]()
        self.desired_occupation = data["desired_occupation"] as? [String] ?? [String]()
        self.desired_job_area = data["desired_job_area"] as? [String] ?? [String]()
        self.student_card = data["student_card"] as? String ?? ""
        self.id_card = data["id_card"] as? String ?? ""
        self.profile_icon = data["profile_icon"] as? String ?? ""
        self.header_img = data["header_img"] as? String ?? ""
        self.is_activated = data["is_activated"] as? Bool ?? true
        self.is_deleted = data["is_deleted"] as? Bool ?? false
        self.is_follow_notification = data["is_follow_notification"] as? Bool ?? true
        self.is_comment_notification = data["is_comment_notification"] as? Bool ?? true
        self.is_message_notification = data["is_message_notification"] as? Bool ?? true
        self.is_retweet_notification = data["is_retweet_notification"] as? Bool ?? true
        self.logined_at = data["logined_at"] as? Timestamp ?? Timestamp()
        
    }
}
