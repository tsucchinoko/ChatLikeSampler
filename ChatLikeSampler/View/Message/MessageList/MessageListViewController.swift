//
//  MessageListViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/10/21.
//

import UIKit
import Firebase

class MessageListViewController: UIViewController {
    
    private let cellId = "cellId"
    private var roomMessages = [Message]()
    private var rooms = [Room]()
    private var users = [User]()
    let myQueue = DispatchQueue(label: "キュー")
    
    @IBOutlet weak var messageListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchMessageRoomInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let email = "dev_tsuchiya04@gmail.com"
        let password = "123456"
//        Auth.auth().signIn(withEmail: "dev_tsuchiya@gmail.com", password: "123456", completion: nil)
        Auth.auth().createUser(withEmail: email, password: password, completion: nil)
    }
    
    // Viewのセットアップ
    private func setupViews() {
        messageListTableView.tableFooterView = UIView()
        messageListTableView.delegate = self
        messageListTableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor =  UIColor.rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    
    // メッセージ一覧画面の情報を取得
    private func fetchMessageRoomInfoFromFirestore() {
        // ルーム情報の取得
        Firestore.firestore().collection("rooms").addSnapshotListener { (snapshots, err) in
            if let err = err {
                print("ルーム情報の取得失敗: \(err)")
                return
            }
            
            // ルーム内の変化を監視
            snapshots?.documentChanges.forEach( { (documentChange) in
                switch documentChange.type {
                case .added:
                    self.handleAddedDocumentChange(documentChange: documentChange)
                case .modified:
                    self.handleUpdatedDocumentChange(documentChange: documentChange)
                case .removed:
                    print("nothing to do")
                }
            })
        }
        self.messageListTableView.reloadData()
        print("END!!!")
    }
    
    // ドキュメント追加時のハンドラー
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let data = documentChange.document.data()
        let room = Room(data: data)
        room.roomId = documentChange.document.documentID
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // 自分の参加しているルームのみ表示
        let isContain = room.members.contains(uid)
        if !isContain { return }
        
        // ルーム内のユーザー情報を取得
        room.members.forEach{ (memberUid) in
            if memberUid != uid {
                // ユーザー情報取得
                Firestore.firestore().collection("users").document(memberUid).getDocument{ (snapshot, err) in
                    if let err = err {
                        print("ユーザー情報取得失敗: \(err)")
                        return
                    }
                    
                    guard let data = snapshot?.data() else { return }
                    let user = User(data: data)
                    user.uid = documentChange.document.documentID
                    room.partnerUser = user
                    self.users.append(user)
                    
                    guard let roomId = room.roomId else { return }
                    let latestMessageId = room.latestMessageId
                    
                    // ルーム内の会話履歴がない場合
                    if latestMessageId == "" {
                        self.rooms.append(room)
                        self.messageListTableView.reloadData()
                        return
                    }
                    
                    // 最新メッセージの取得
                    Firestore.firestore().collection("rooms").document(roomId).collection("messages").document(latestMessageId).getDocument{ (messageSnapshot, err) in
                        if let err = err {
                            print("最新メッセージの取得失敗: \(err)")
                            return
                        }
                        guard let data = messageSnapshot?.data() else { return }
                        let message = Message(data: data)
                        room.latestMessage = message
                        print("latestMessage: \(message)")
                        
                        self.messageListTableView.reloadData()
                    }
                    
                    // 未読数の取得
                    Firestore.firestore().collection("rooms").document(roomId).collection("messages").whereField("read", isEqualTo: false).getDocuments { (querySnapshot, err) in
                        if let err = err {
                            print("未読数の取得失敗: \(err)")
                            return
                        }
                        
                        for _ in querySnapshot!.documents {
                            room.unreadCount += 1
                        }
                        
                        self.rooms.append(room)
                        self.messageListTableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    // ドキュメント更新時のハンドラ
    private func handleUpdatedDocumentChange(documentChange: DocumentChange) {
        let data = documentChange.document.data()
        let changeRoom = Room(data: data)
        changeRoom.roomId = documentChange.document.documentID
        
        var roomIndex = 0
        
        // 更新対象のRoomのIndexを取得
        for (index, room) in rooms.enumerated() {
            if room.roomId == changeRoom.roomId {
                roomIndex = index
                print("roomIndex!!: \(roomIndex)")
            }
        }
        
        // 最新メッセージの取得
        Firestore.firestore().collection("rooms").document(changeRoom.roomId!).collection("messages").document(changeRoom.latestMessageId).getDocument{ (messageSnapshot, err) in
            if let err = err {
                print("最新メッセージの取得失敗: \(err)")
                return
            }
            guard let data = messageSnapshot?.data() else { return }
            let message = Message(data: data)
            changeRoom.latestMessage = message
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            changeRoom.members.forEach{ (memberUid) in
                // 自分が送信したメッセージの未読をカウントしない
                if memberUid != uid {
                    for (index, user) in self.users.enumerated() {
                        print("index!!: \(index)")
                        print("user!! : \(user)")
                        print("userUid!! : \(user.uid)")
                        print("memberUid!! : \(memberUid)")
                        if user.uid == memberUid {
                            changeRoom.partnerUser = user
                        }
                    }
                    
                    // 未読数の取得
                    Firestore.firestore().collection("rooms").document(changeRoom.roomId!).collection("messages").whereField("read", isEqualTo: false).getDocuments { (querySnapshot, err) in
                        if let err = err {
                            print("未読数の取得失敗: \(err)")
                            return
                        }
                        
                        for _ in querySnapshot!.documents {
                            changeRoom.unreadCount += 1
                        }
                        self.rooms[roomIndex] = changeRoom
                        self.messageListTableView.reloadData()
                    }
                }
            }

        }
    }
    
    // 最新メッセージの取得
    private func fetchLatestMessage(documentChange: DocumentChange){
        let data = documentChange.document.data()
        let room = Room(data: data)
        room.roomId = documentChange.document.documentID
        
        guard let roomId = room.roomId else { return }
        let latestMessageId = room.latestMessageId
        
        // 最新メッセージの取得
        Firestore.firestore().collection("rooms").document(roomId).collection("messages").document(latestMessageId).getDocument{ (messageSnapshot, err) in
            if let err = err {
                print("最新メッセージの取得失敗: \(err)")
                return
            }
            guard let data = messageSnapshot?.data() else { return }
            let message = Message(data: data)
            room.latestMessage = message
            print("latestMessage: \(message)")
            
            self.rooms.append(room)
            self.messageListTableView.reloadData()
        }
    }
    
    // 未読数の取得
    private func getUnreadCount(documentChange: DocumentChange){
        let data = documentChange.document.data()
        let room = Room(data: data)
        room.roomId = documentChange.document.documentID
        
        guard let roomId = room.roomId else { return }
        
        // 未読数の取得
        Firestore.firestore().collection("rooms").document(roomId).collection("messages").whereField("read", isEqualTo: false).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("未読数の取得失敗: \(err)")
                return
            }
            
            for _ in querySnapshot!.documents {
                room.unreadCount += 1
            }
            
            self.rooms.append(room)
            self.messageListTableView.reloadData()
        }
    }
    
}



extension MessageListViewController: UITableViewDelegate, UITableViewDataSource {
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    // カスタムセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageListTableViewCell
        cell.room = rooms[indexPath.row]
        
        return cell
    }
    
    // セル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard.init(name: "MessageRoom", bundle: nil)
        // ストーリーボードIDを指定して画面遷移
        let messageVC = storyBoard.instantiateViewController(withIdentifier: "MessageRoomViewController") as! MessageRoomViewController
        guard let roomId = rooms[indexPath.row].roomId else { return }
        messageVC.roomId = roomId
        
        navigationController?.pushViewController(messageVC, animated: true)
    }
}

class MessageListTableViewCell: UITableViewCell {
    
    // roomに値がセットされたら呼ばれる
    var room: Room? {
        didSet {
            if let room = room {
                partnerLabel.text = room.partnerUser?.username
                dateLabel.text = dateFormatterForDateLabel(date: room.latestMessage?.created_at.dateValue() ?? Date())
                latestMessageLabel.text = room.latestMessage?.text
                if room.unreadCount == 0 {
                    unreadLabel.isHidden = true
                } else {
                    unreadLabel.text = String(room.unreadCount)
                }
            }
        }
    }
    
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var unreadLabel: UILabel!
    
    // カスタムセルを初期化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        unreadLabel.layer.cornerRadius = unreadLabel.frame.width / 2
        unreadLabel.clipsToBounds = true
    }
    
    // カスタムセル選択時
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // 日付をフォーマットする
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        
        return formatter.string(from: date)
    }
}




