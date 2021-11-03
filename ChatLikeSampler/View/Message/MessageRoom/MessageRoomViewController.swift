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
    
    let email = "dev_tsuchiya@gmail.com"
    let password = "123456"
    
    private let partnerCellId = "partnerCellId"
    private let myCellId = "myCellId"
    private var messages = [String]()
    
    private lazy var messageInputAccessoryView: MessageInputAccessoryView = {
        let view = MessageInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: 100)
        view.delegate = self
        return view
    }()
    
    @IBOutlet weak var messageRoomTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageRoomTableView.delegate = self
        messageRoomTableView.dataSource = self
        // tableViewにセルを登録
        messageRoomTableView.register(UINib(nibName: "PartnerMessageTableViewCell", bundle: nil), forCellReuseIdentifier: partnerCellId)
        messageRoomTableView.register(UINib(nibName: "MyMessageTableViewCell", bundle: nil), forCellReuseIdentifier: myCellId)
    }
    
    private func checkWitchUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("uid: \(uid)")
        
        //        if uid == PartnerMessageTableViewCell().messageText?.uid{
        
        //        }
    }
    
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
        messages.append(text)
        
        // UID取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("uid!: \(uid)")
        let sendTime = Timestamp()
        let sendData = [
            "author": uid,
            "text": text,
            "image": "image",
            "read": false,
            "created_at": sendTime,
            "updated_at": sendTime,
        ] as [String : Any]
        
        let db = Firestore.firestore()
        if db == nil {
            print("DB == nil !!!")
        }
        // Add a new document with a generated ID
        var ref: DocumentReference? = nil
        ref = Firestore.firestore().collection("rooms").addDocument(data: sendData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }
        messageInputAccessoryView.removeText()
        messageRoomTableView.reloadData()
        
        /*
         "rooms" : {
         "0" : {
         "name" : "test room",
         "messages" : {
         "0" : {
         "author" : "test",
         "text" : "message test",
         "image" : "https://xxx.com/images/room/0/messages/0/message.png",
         "read" : false,
         "created_at" : "2021-09-13 18:10:00",
         "updated_at" : "2021-09-13 18:20:00"
         }
         },
         "creator" : "test@example.com",
         "created_at" : "2021-09-13 18:10:00",
         "updated_at" : "2021-09-13 18:20:00"
         }
         },
         
         */
        // TODO
        // rooms[0]["messages"][0]["author"]で判断する？
        // rooms[0]["messages"][0]["text"] = text
        // rooms[0]["messages"][x]["author"]がuidと一致するかどうか！
        

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
        return messages.count
    }
    
    // カスタムセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let partnerCell = messageRoomTableView.dequeueReusableCell(withIdentifier: partnerCellId, for: indexPath) as! PartnerMessageTableViewCell
        partnerCell.messageText = messages[indexPath.row]
        
        let myCell = messageRoomTableView.dequeueReusableCell(withIdentifier: myCellId, for: indexPath) as! MyMessageTableViewCell
        myCell.messageText = messages[indexPath.row]
        
        return myCell
    }
}

extension MessageRoomViewController: UIImagePickerControllerDelegate {
}

extension MessageRoomViewController: UINavigationControllerDelegate {
}
