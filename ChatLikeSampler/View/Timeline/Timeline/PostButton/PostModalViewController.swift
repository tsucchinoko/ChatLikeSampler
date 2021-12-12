//
//  PostModalViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/12/06.
//

import UIKit
import Firebase

class PostModalViewController: UIViewController {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupViews()
    }
    
    private func setupViews(){
        postTextView.delegate = self
        postTextView.text = ""
        postTextView.layer.borderColor = UIColor.systemGray6.cgColor
        postTextView.layer.borderWidth = 1
        
        postButton.isEnabled = false
    }
    
    @IBAction func didTappedBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTappedPostButton(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let email = Auth.auth().currentUser?.email else { return }
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { userSnapshots, err in
            if let err = err {
                print("ユーザ情報の取得に失敗しました: \(err)")
                return
            }
            
            guard let snapshots = userSnapshots?.documents else { return }
            for snapshot in snapshots {
                if snapshot.documentID == uid {
                    let userInfo = User(document: snapshot)
                    let sendTime = Timestamp()
                    let sendData = [
                        "text": "",
                        "image": nil,
                        "creator": userInfo.username!,
                        "is_deleted": false,
                        "created_at": sendTime,
                        "updated_at": sendTime
                    ] as [String : Any?]
                    
                    self.db.collection("tweets").addDocument(data: sendData) { err in
                        if let err = err {
                            print("ツイートに失敗しました: \(err)")
                            return
                        }
                        print("#ツイートしました！")
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension PostModalViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if postTextView.text.isEmpty {
            postButton.isEnabled = false
        } else {
            postButton.isEnabled = true
        }
    }
}
