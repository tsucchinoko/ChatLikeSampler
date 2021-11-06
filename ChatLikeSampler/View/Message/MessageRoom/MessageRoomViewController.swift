//
//  MessageRoomViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/10/21.
//

import UIKit
import Firebase
import FirebaseAuth

class MessageRoomViewController: UIViewController {
    
    private let partnerCellId = "partnerCellId"
    private let myCellId = "myCellId"
    
    var documentId = ""
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
    }
    
    private func checkWitchUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("uid: \(uid)")
    }
    
    // メッセージ情報を取得
    private func fetchMessageInfoFromFirestore() {
        Firestore.firestore().collection("rooms").document(documentId).collection("messages")
            .addSnapshotListener{ (snapshots, err) in
                if let err = err {
                    print("メッセージ取得失敗: \(err)")
                }
                snapshots?.documentChanges.forEach( {(documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.handleAddedDocumentChange(documentChange: documentChange)
                        
                    case .modified, .removed:
                        print("nothing to do")
                    }
                })
                
                self.messageRoomTableView.reloadData()
            }
    }
    
    // ドキュメント追加時のハンドラー
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let data = documentChange.document.data()
        let message = Message(data: data)
        self.roomMessages.append(message)
    }
    
    // Firestoreにメッセージを送信
    private func sendMessageToFirestore(text: String) {
        // UID取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let sendTime = Timestamp()
        let sendData = [
            "author": uid,
            "text": text,
            "image": "image",
            "read": false,
            "created_at": sendTime,
            "updated_at": sendTime,
        ] as [String : Any]
        
        
        // ここ重要！！
        Firestore.firestore().collection("rooms").document(documentId).collection("messages").document()
            .setData(sendData, merge: true){ err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document successfully written!")
                }
            }
    }
    
    private func uploadImageToFireStorage(imageView: UIImageView) {
        guard let image = imageView.image else { return }
        guard let uploadImage = image.jpegData(compressionQuality: 0.3) else { return }
        
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("sendImage").child(fileName)
        
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
        let partnerCell = messageRoomTableView.dequeueReusableCell(withIdentifier: partnerCellId, for: indexPath) as! PartnerMessageTableViewCell
        partnerCell.message = roomMessages[indexPath.row]
        
        let myCell = messageRoomTableView.dequeueReusableCell(withIdentifier: myCellId, for: indexPath) as! MyMessageTableViewCell
        myCell.message = roomMessages[indexPath.row]
        
        return myCell
    }
}

extension MessageRoomViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let origialImage = info[.originalImage] as? UIImage {
            print("originalImage!!")
        }
        
        dismiss(animated: true, completion: nil)
    }
}

extension MessageRoomViewController: UINavigationControllerDelegate {
}
