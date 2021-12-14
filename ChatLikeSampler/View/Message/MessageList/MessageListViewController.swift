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
    private var rooms = [Room]()
    private var users = [User]()
    var db: Firestore!
    
    @IBOutlet weak var messageListTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupViews()
        fetchMessageRoomInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        db.collection("rooms").addSnapshotListener { (snapshots, err) in
            if let err = err {
                print("ルーム情報の取得失敗: \(err)")
                return
            }
            
            // ルーム内の変化を監視
            snapshots?.documentChanges.forEach( { (documentChange) in
                switch documentChange.type {
                case .added:
                    self.handleAddedDocumentChange(roomsDocumentChanges: documentChange)
                case .modified:
                    self.handleUpdatedDocumentChange(roomsDocumentChanges: documentChange)
                case .removed:
                    print("nothing to do")
                }
            })
        }
        self.messageListTableView.reloadData()
    }
    
    // ドキュメント追加時のハンドラー
    private func handleAddedDocumentChange(roomsDocumentChanges: DocumentChange) {
//        let data = roomsDocumentChanges.document.data()
//        let room = Room(data: data)
//        room.roomId = roomsDocumentChanges.document.documentID
        
        let room = Room(document: roomsDocumentChanges.document)

        guard let uid = Auth.auth().currentUser?.uid else { return }
        // 自分の参加しているルームのみ表示
        let isContain = room.members.contains(uid)
        if !isContain { return }
        
        // ルーム内のユーザー情報を取得
        room.members.forEach{ (memberUid) in
            if memberUid != uid {
                // ユーザー情報取得
                db.collection("users").document(memberUid).getDocument{ (userDocument, err) in
                    if let err = err {
                        print("ユーザー情報取得失敗: \(err)")
                        return
                    }
                    
                    guard let userDocument = userDocument else { return }
                    let user = User(document: userDocument)
                    user.uid = memberUid
                    self.users.append(user)
                    room.partnerUser = user
                    
                    
                    guard let roomId = room.roomId else { return }
                    let latestMessageId = room.latestMessageId
                    
                    // ルーム内の会話履歴がない場合
                    if latestMessageId == "" {
                        self.rooms.append(room)
                        // 日付順にソート
                        self.rooms.sort{ (m1, m2) -> Bool in
                            let m1Date = m1.updated_at.dateValue()
                            let m2Date = m2.updated_at.dateValue()
                            return m1Date < m2Date
                        }
                        self.messageListTableView.reloadData()
                        return
                    }
                    
                    // 最新メッセージの取得
                    self.db.collection("rooms").document(roomId).collection("messages").document(latestMessageId).getDocument{ (latestMessageDocument, err) in
                        if let err = err {
                            print("最新メッセージの取得失敗: \(err)")
                            return
                        }
                        guard let document = latestMessageDocument else { return }
                        let message = Message(document: document)
                        room.latestMessage = message
                        
                        self.messageListTableView.reloadData()
                    }
                    
                    // 未読数の取得
                    self.db.collection("rooms").document(roomId).collection("messages").whereField("read", isEqualTo: false).getDocuments { (unreadDocuments, err) in
                        if let err = err {
                            print("未読数の取得失敗: \(err)")
                            return
                        }
                        
                        for document in unreadDocuments!.documents {
                            let message = Message(document: document)
                            let author = message.author
                            if author != uid {
                                room.unreadCount += 1
                            }
                        }
                        
                        self.rooms.append(room)
                        // 日付順にソート
                        self.rooms.sort{ (m1, m2) -> Bool in
                            let m1Date = m1.updated_at.dateValue()
                            let m2Date = m2.updated_at.dateValue()
                            return m1Date < m2Date
                        }
                        self.messageListTableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    // ドキュメント更新時のハンドラ
    private func handleUpdatedDocumentChange(roomsDocumentChanges: DocumentChange) {
        let changeRoom = Room(document: roomsDocumentChanges.document)
        
        var roomIndex = 0
        
        // 更新対象のRoomのIndexを取得
        for (index, room) in rooms.enumerated() {
            if room.roomId == changeRoom.roomId {
                roomIndex = index
                print("roomIndex!!: \(roomIndex)")
            }
        }
        
        // 最新メッセージの取得
        db.collection("rooms").document(changeRoom.roomId!).collection("messages").document(changeRoom.latestMessageId).getDocument{ (messageSnapshot, err) in
            if let err = err {
                print("最新メッセージの取得失敗: \(err)")
                return
            }
            guard let document = messageSnapshot else { return }
            let message = Message(document: document as! QueryDocumentSnapshot)
            changeRoom.latestMessage = message
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            changeRoom.members.forEach{ (memberUid) in
                // 自分が送信したメッセージの未読をカウントしない
                if memberUid != uid {
                    for (index, user) in self.users.enumerated() {
                        if user.uid == memberUid {
                            changeRoom.partnerUser = user
                        }
                    }
                    
                    // 未読数の取得
                    self.db.collection("rooms").document(changeRoom.roomId!).collection("messages").whereField("read", isEqualTo: false).getDocuments { (querySnapshot, err) in
                        if let err = err {
                            print("未読数の取得失敗: \(err)")
                            return
                        }
                        
                        for document in querySnapshot!.documents {
                            let message = Message(document: document)
                            let author = message.author
                            if author != uid {
                                changeRoom.unreadCount += 1
                            }
                        }
                        self.rooms[roomIndex] = changeRoom
                        self.messageListTableView.reloadData()
                    }
                }
            }

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
        
        rooms[indexPath.row].unreadCount = 0
        
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




