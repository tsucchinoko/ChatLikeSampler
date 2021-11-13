//
//  MessageRoomViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/10/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
//import Nuke

class MessageRoomViewController: UIViewController {
    
    private let partnerCellId = "partnerCellId"
    private let myCellId = "myCellId"
    
    var roomId = ""
    private var roomMessages = [Message]()
    
    private lazy var messageInputAccessoryView: MessageInputAccessoryView = {
        let view = MessageInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    @IBOutlet weak var messageRoomTableView: UITableView!
    
    // messageInputAccessoryViewとキーボードを紐付け
    override var inputAccessoryView: UIView? {
        get {
            return messageInputAccessoryView
        }
    }
    
    // messageInputAccessoryViewがfirstResponderになれるよう設定
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchMessageInfoFromFirestore()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // Viewのセットアップ
    private func setupViews(){
        messageRoomTableView.delegate = self
        messageRoomTableView.dataSource = self
        // tableViewにセルを登録
        messageRoomTableView.register(UINib(nibName: "PartnerMessageTableViewCell", bundle: nil), forCellReuseIdentifier: partnerCellId)
        messageRoomTableView.register(UINib(nibName: "MyMessageTableViewCell", bundle: nil), forCellReuseIdentifier: myCellId)
        
        // セルが見切れないように位置を微調整
        messageRoomTableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        // スクロールバーの位置を微調整
        messageRoomTableView.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 60, right: 0)
        // スクロール時にキーボードを閉じる
        messageRoomTableView.keyboardDismissMode = .interactive
    }
    
    // メッセージ送信者の判別
    private func checkWitchUserMessage(indexPath: IndexPath) -> UITableViewCell {
        guard let uid = Auth.auth().currentUser?.uid else { return UITableViewCell() }
        
        if uid == roomMessages[indexPath.row].author {
            let myCell = messageRoomTableView.dequeueReusableCell(withIdentifier: myCellId, for: indexPath) as! MyMessageTableViewCell
            myCell.message = roomMessages[indexPath.row]
            return myCell
        } else {
            let partnerCell = messageRoomTableView.dequeueReusableCell(withIdentifier: partnerCellId, for: indexPath) as! PartnerMessageTableViewCell
            partnerCell.message = roomMessages[indexPath.row]
            return partnerCell
        }
    }
    
    // メッセージ情報を取得
    private func fetchMessageInfoFromFirestore() {
        Firestore.firestore().collection("rooms").document(roomId).collection("messages")
            .addSnapshotListener{ (snapshots, err) in
                if let err = err {
                    print("メッセージ取得失敗: \(err)")
                }
                snapshots?.documentChanges.forEach( {(documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                        self.updateUnreadFlagOfFirestore(documentChange: documentChange)

                        
                    case .modified:
                        self.updateUnreadFlagOfFirestore(documentChange: documentChange)
                        
                    case .removed:
                        print("nothing to do")
                    }
                })
                
                self.messageRoomTableView.reloadData()
                self.messageRoomTableView.scrollToRow(at: IndexPath(row: self.roomMessages.count - 1, section: 0), at: .bottom, animated: false)
            }
    }
    
    // ドキュメント追加時のハンドラー
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let data = documentChange.document.data()
        let message = Message(data: data)
        self.roomMessages.append(message)
        // 日付順にソート
        self.roomMessages.sort{ (m1, m2) -> Bool in
            let m1Date = m1.created_at.dateValue()
            let m2Date = m2.created_at.dateValue()
            return m1Date < m2Date
        }
    }
    
    // 既読時
    private func updateUnreadFlagOfFirestore(documentChange: DocumentChange) {

        guard let uid = Auth.auth().currentUser?.uid else { return }
        let documentId = documentChange.document.documentID
        let data = documentChange.document.data()
        let message = Message(data: data)
        let author = message.author

        // 相手のメッセージの既読フラグをTrueに更新
        if author != uid {
            Firestore.firestore().collection("rooms").document(self.roomId)
                .collection("messages").document(documentId).updateData(["read": true])
        }
        self.messageRoomTableView.reloadData()
    }
    
    // 既読ラベルの表示
    private func showReadLabel(indexPath: IndexPath) {
//        let indexPath = IndexPath(row: row, section: section)
//        self.messageRoomTableView.reloadRows(at: [indexPath], with: .fade)
    }

    
    // Firestoreにメッセージを送信
    private func sendMessageToFirestore(text: String) {
        // UID取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // 最新メッセージの取得を簡略化するため、アプリ側でIDを生成
        let messageId = randomString(length: 20)
        let sendTime = Timestamp()
        let sendData = [
            "author": uid,
            "text": text,
            "image": "image",
            "read": false,
            "created_at": sendTime,
            "updated_at": sendTime,
        ] as [String : Any]
        
        // Firestoreにメッセージを送信
        Firestore.firestore().collection("rooms").document(roomId).collection("messages").document(messageId)
            .setData(sendData, merge: true){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
        
        let latestMessageData = [
            "latestMessageId": messageId
        ]
        
        // FirestoreのlatestMessageを更新
        Firestore.firestore().collection("rooms").document(roomId).updateData(latestMessageData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    // 画像送信時
    private func uploadImageToFireStorage(image: UIImage) {
//        guard let image = image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child(roomId).child(fileName)
        
        storageRef.putData(uploadImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("FireStorageへの保存失敗: \(err)")
                return
            }
            
            print("FireStoregeへの保存成功")
            storageRef.downloadURL(completion: {(url, err) in
                if let err = err {
                    print("FireStorageからのダウンロード失敗: \(err)")
                    return
                }
                
                guard let urlString = url?.absoluteString else { return }
                print("URLString: \(urlString)")
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
}


extension MessageRoomViewController: MessageInputAccessoryViewDelegate {
    
    // ファイル追加ボタン押下時
    func tappedFileAddButton() {
        print(#function)
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // 送信ボタン押下時
    func tappedSendButton(text: String) {
        
        sendMessageToFirestore(text: text)
        messageInputAccessoryView.removeText()
        messageRoomTableView.reloadData()
    }
}

extension MessageRoomViewController: UITableViewDelegate, UITableViewDataSource {
    
    // セルの高さを決定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 高さ(min)を設定
        messageRoomTableView.estimatedRowHeight = 20
        // テキストビューの高さによってセルの高さを自動で変化させる
        return UITableView.automaticDimension
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomMessages.count
    }
    
    // カスタムセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = checkWitchUserMessage(indexPath: indexPath)
        
        return cell
    }
}

extension MessageRoomViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
//            let cell = messageRoomTableView.dequeueReusableCell(withIdentifier: myCellId) as! MyMessageTableViewCell
//            cell.sendImageView.image = editImage
//            cell.sendImageView.isHidden = false
            uploadImageToFireStorage(image: editImage)
        } else if let originalImage = info[.originalImage] as? UIImage {
//            let cell = messageRoomTableView.dequeueReusableCell(withIdentifier: myCellId) as! MyMessageTableViewCell
//            cell.sendImageView.image = originalImage
            uploadImageToFireStorage(image: originalImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension MessageRoomViewController: UINavigationControllerDelegate {
}
