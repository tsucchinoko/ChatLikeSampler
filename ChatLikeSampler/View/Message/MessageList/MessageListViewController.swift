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
    var roomNames = [String]()
    
    @IBOutlet weak var messageListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchMessageRoomInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //        Auth.auth().createUser(withEmail: "dev_tsuchiya2@email.com", password: "123456", completion: nil)
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
        Firestore.firestore().collection("rooms").addSnapshotListener { (snapshots, err) in
            if let err = err {
                print("ルーム情報の取得失敗: \(err)")
                return
            }
            
            snapshots?.documentChanges.forEach( { (documentChange) in
                switch documentChange.type {
                case .added:
                    self.handleAddedDocumentChange(documentChange: documentChange)
                case .modified, .removed:
                    print("nothing to do")
                }
            })
        }
    }
    
    // ドキュメント追加時のハンドラー
    private func handleAddedDocumentChange(documentChange: DocumentChange) {
        let data = documentChange.document.data()
        let room = Room(data: data)
        room.roomId = documentChange.document.documentID
        
        // 自分の参加しているルームのみ表示
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let isContain = room.members.contains(uid)
        if !isContain { return }
        
        room.members.forEach{ (memberUid) in
            if memberUid != uid {
                Firestore.firestore().collection("users").document(memberUid).getDocument{ (snapshot, err) in
                    if let err = err {
                        print("ユーザー情報取得失敗: \(err)")
                        return
                    }
                    
                    guard let data = snapshot?.data() else { return }
                    let user = User(data: data)
                    user.uid = documentChange.document.documentID
                    room.partnerUser = user
                    
                    guard let roomId = room.roomId else { return }
                    let latestMessageId = room.latestMessageId
                    
                    if latestMessageId == "" {
                        self.rooms.append(room)
                        self.messageListTableView.reloadData()
                        return
                    }
                    
                    Firestore.firestore().collection("rooms").document(roomId).collection("messages").document(latestMessageId).getDocument{ (messageSnapshot, err) in
                        if let err = err {
                            print("最新メッセージの取得失敗: \(err)")
                            return
                        }
                        guard let data = messageSnapshot?.data() else { return }
                        let message = Message(data: data)
                        room.latestMessage = message
                        
                        self.rooms.append(room)
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
        messageVC.roomIds = rooms[indexPath.row].roomId ?? ""
        
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
            }
        }
    }
    
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    // カスタムセルを初期化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
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




