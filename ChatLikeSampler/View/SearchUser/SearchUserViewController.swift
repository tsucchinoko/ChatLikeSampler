//
//  SearchUserViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/12/06.
//

import UIKit
import Firebase


class SearchUserViewController: UIViewController {
    
    private let cellId = "userListCellId"
    private var users = [User]()
    var db: Firestore!
    
    let mainQueue = DispatchQueue.main
    
    @IBOutlet weak var userSearchBar: UISearchBar!
    
    @IBOutlet weak var preferenceButton: UIButton!
    
    @IBOutlet weak var userListTableView: UITableView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupViews()
        fetchUserInfoFromFirestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshTableView()
    }
    
    private func setupViews(){
        userSearchBar.backgroundImage = UIImage()
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        
    }
    
    private func fetchUserInfoFromFirestore(){
        db.collection("users").getDocuments { userSnapshots, err in
            if let err = err {
                print("ユーザー情報の取得に失敗しました: \(err)")
                return
            }
            
            // Tweet情報を配列に格納
            guard let snapshots = userSnapshots?.documents else { return }
            self.users = snapshots.map { document in
                let user = User(document: document)
                return user
            }
        }
    }
    

    @IBAction func didTappedPreferenceButton(_ sender: Any) {
    }
    
    
    func refreshTableView() {
        // 応急処置のため非同期処理用に修正
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.userListTableView.reloadData()
            print("isMainThread??: \(Thread.current.isMainThread)")
        }
    }
    
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        userListTableView.estimatedRowHeight = 100
        // テキストビューの高さによってセルの高さを自動で変化させる
//        return UITableView.automaticDimension
        return 80
    }
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // カスタムセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userListTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}



class UserListTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userAboutTextView: UITextView! {
        didSet {
            userAboutTextView.isUserInteractionEnabled = false
        }
    }
    
    var user: User? {
        didSet {
            if let user = user {
//                TODO String -> UIImage
//                userImageView.image = UIImage(user.profile_icon)
                userNameLabel.text = user.username
                userAboutTextView.text = user.about

//                dateLabel.text = dateFormatterForDateLabel(date: room.latestMessage?.created_at.dateValue() ?? Date())
            }
        }
    }
    
    
    
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
