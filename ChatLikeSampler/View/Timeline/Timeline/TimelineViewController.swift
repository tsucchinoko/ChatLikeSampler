//
//  TimelineViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit
import Firebase

class TimelineViewController: UIViewController {
    let cellId = "timelineCell"
    
    var tweets = [Tweet]()
    var db: Firestore!
    
    @IBOutlet weak var timelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        db = Firestore.firestore()
        setupViews()
        fetchTimelineInfoFromFirestore()
    }
    
    private func setupViews() {
        navigationController?.navigationBar.barTintColor =  UIColor.rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "タイムライン画面"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        // tableViewにセルを登録
        timelineTableView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        // セルが見切れないように位置を微調整
        //        timelineTableView.contentInset = tebleViewContentInset
        //        // スクロールバーの位置を微調整
        //        timelineTableView.scrollIndicatorInsets = tableViewIndicatorInset
        // スクロール時にキーボードを閉じる
        timelineTableView.keyboardDismissMode = .interactive
        timelineTableView.refreshControl = UIRefreshControl()
        timelineTableView.refreshControl?.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
        
    }
    
    // タイムライン情報の取得
    private func fetchTimelineInfoFromFirestore(){
        // Tweetを取得
        db.collection("tweets").getDocuments { tweetsSnapshots, err in
            if let err = err {
                print("Tweet情報の取得失敗: \(err)")
                return
            }
            
            guard let snapshots = tweetsSnapshots?.documents else { return }
            for snapshot in snapshots {
                let data = snapshot.data()
                let tweet = Tweet(data: data)
                tweet.documentId = snapshot.documentID
                
                self.tweets.append(tweet)
            }
            self.timelineTableView.reloadData()
            
        }
        
    }
    
    // tableViewを下に引っ張ったときにインジケーターを表示
    @objc func refreshTableView() {
        // TODO 値が取得できるまで待機
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.timelineTableView.refreshControl?.endRefreshing()
        }
    }
    
}

extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    // カスタムセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = timelineTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TimelineCell
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        print("#tweets[indexPath.row].likes: \(tweets[indexPath.row].likes!)")
        // tagを追加し、どのセルのボタンか判別
        cell.tag = indexPath.row
        
        return cell
    }
    
    // セル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard.init(name: "TimelineDetailViewController", bundle: nil)
        // ストーリーボードIDを指定して画面遷移
        let timelineDetailVC = storyBoard.instantiateViewController(withIdentifier: "TimelineDetailViewController") as! TimelineDetailViewController
        timelineDetailVC.tweet = tweets[indexPath.row]
        
        
        navigationController?.pushViewController(timelineDetailVC, animated: true)
        timelineTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}


extension TimelineViewController: TimelineCellDelegate {
    func didTappedCommentButton(cell: TimelineCell) {
        print(#function)
        // ストーリーボードIDを指定して画面遷移
        let storyBoard = UIStoryboard.init(name: "TimelineDetailViewController", bundle: nil)
        let timelineDetailVC = storyBoard.instantiateViewController(withIdentifier: "TimelineDetailViewController") as! TimelineDetailViewController
        timelineDetailVC.tweet = tweets[cell.tag]
        navigationController?.pushViewController(timelineDetailVC, animated: true)
    }
    
    func didTappedRetweetButton(cell: TimelineCell) {
        print(#function)
        let backImage = UIImage(systemName: "repeat")?.withRenderingMode(.alwaysTemplate)
        cell.retweetButton.setImage(backImage, for: .normal)
        cell.retweetButton.tintColor = .green
        
        // リツイート数の更新
        var count = tweets[cell.tag].retweets?.count ?? 0
        count += 1
        cell.retweetNumberLabel.text = String(count)
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let email = Auth.auth().currentUser?.email else { return }
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { userSnapshots, err in
            if let err = err {
                print("ユーザ情報の取得に失敗しました: \(err)")
                return
            }
            
            guard let snapshots = userSnapshots?.documents else { return }
            for snapshot in snapshots {
                print("#snapshot.documentID: \(snapshot.documentID)")
                print("#uid: \(uid)")
                if snapshot.documentID == uid {
                    let data = snapshot.data()
                    let userInfo = User(data: data)
                    let likeTime = Timestamp()
                    let retweetData = [
                        "profile_icon": userInfo.profile_icon,
                        "email": userInfo.email,
                        "username": userInfo.username,
                        "about": userInfo.about,
                        "created_at": likeTime,
                        "updated_at": likeTime
                    ] as! [String: Any]
                    
                    guard let documentId = self.tweets[cell.tag].documentId else { return }
                    self.db.collection("tweets").document(documentId).collection("retweets").addDocument(data: retweetData) { err in
                        if let err = err {
                            print("リツイート情報の追加に失敗しました: \(err)")
                            return
                        }
                        // TODO: 自分の投稿に追加
                        print("#リツイートしました！")
                    }
                    
                }
            }
        }
        
    }
    
    func didTappedLikeButton(cell: TimelineCell) {
        print(#function)
        let backImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        cell.likeButton.setImage(backImage, for: .normal)
        cell.likeButton.tintColor = .systemPink
        
        // いいね数の更新
        var count = tweets[cell.tag].likes?.count ?? 0
        count += 1
        cell.likeNumberLabel.text = String(count)
        print(count)
        
        // TODO ローカルDBから自分のユーザ情報とってきたい
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let email = Auth.auth().currentUser?.email else { return }
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { userSnapshots, err in
            if let err = err {
                print("ユーザ情報の取得に失敗しました: \(err)")
                return
            }
            
            guard let snapshots = userSnapshots?.documents else { return }
            for snapshot in snapshots {
                print("#snapshot.documentID: \(snapshot.documentID)")
                print("#uid: \(uid)")
                if snapshot.documentID == uid {
                    let data = snapshot.data()
                    let userInfo = User(data: data)
                    let likeTime = Timestamp()
                    let likeData = [
                        "profile_icon": userInfo.profile_icon,
                        "email": userInfo.email,
                        "username": userInfo.username,
                        "about": userInfo.about,
                        "created_at": likeTime,
                        "updated_at": likeTime
                    ] as! [String: Any]
                    
                    guard let documentId = self.tweets[cell.tag].documentId else { return }
                    self.db.collection("tweets").document(documentId).collection("likes").addDocument(data: likeData) { err in
                        if let err = err {
                            print("いいね情報の追加に失敗しました: \(err)")
                            return
                        }
                        // TODO: いいねした一覧に追加
                        print("#いいねしました！")
                    }
                    
                }
            }
            
        }
        
        
    }
    
    func didTappedFlagButton(cell: TimelineCell) {
        print(#function)
        let backImage = UIImage(systemName: "flag.fill")?.withRenderingMode(.alwaysTemplate)
        cell.flagButton.setImage(backImage, for: .normal)
        cell.flagButton.tintColor = .red
        
        // TODO ポップアップ表示
        // TODO 報告処理
        print(cell.tag)
    }
}
