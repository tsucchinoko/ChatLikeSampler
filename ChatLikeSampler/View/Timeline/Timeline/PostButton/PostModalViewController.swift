//
//  PostModalViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/12/06.
//

import UIKit
import Firebase

class PostModalViewController: UIViewController, UINavigationControllerDelegate{
    
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var postTextView: UITextView!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBOutlet weak var imageClearButton: UIButton!
    
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupViews()
        setupNotifications()
    }
    
    private func setupViews(){
        postTextView.delegate = self
        postTextView.text = ""
        postTextView.layer.borderColor = UIColor.systemGray6.cgColor
        postTextView.layer.borderWidth = 1
        
        postButton.isEnabled = false
    }
    
    private func setupNotifications(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func didTappedBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 画像送信時
    private func uploadImageToFireStorage(image: UIImage) {
        //        guard let image = image else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child(uid).child("tweet").child(fileName)
        
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("FireStorageへの保存失敗: \(err)")
                return
            }
            
            storageRef.downloadURL(completion: {(url, err) in
                if let err = err {
                    print("FireStorageからのダウンロード失敗: \(err)")
                    return
                }
                
                guard let urlString = url?.absoluteString else { return }
                
                // UID取得
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
            })
            
        }
    }
    
    
    // ランダムな文字列を生成
    func randomString(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        return randomString
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
                    
                    if self.postImageView.image != nil {
                        self.uploadImageToFireStorage(image: self.postImageView.image!)
                    }
                }
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTappedImageView(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func didTappedImageClearButton(_ sender: Any) {
        postImageView.image = nil
        imageClearButton.isHidden = true
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.postTextView.resignFirstResponder()
    }
    
    // キーボードを閉じる
    @objc func dismissKeyboard() {
        self.postTextView.resignFirstResponder()
    }
}


extension PostModalViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            postImageView.image = editImage
            imageClearButton.isHidden = false
        } else if let originalImage = info[.originalImage] as? UIImage {
            postImageView.image = originalImage
            imageClearButton.isHidden = false
        }
        
        dismiss(animated: true, completion: nil)
    }
}
//
//extension MessageRoomViewController: UINavigationControllerDelegate {
//}
