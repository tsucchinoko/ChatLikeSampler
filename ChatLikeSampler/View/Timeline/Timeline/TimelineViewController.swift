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
                
                // コメント情報取得
                self.db.collection("tweets").document(tweet.documentId!).collection("comments").getDocuments { commentSnapshots, err in
                    if let err = err {
                        print("コメント情報の取得失敗: \(err)")
                        return
                    }
                    
                    guard let commentSnapshots = commentSnapshots?.documents else { return }
                    for commentSnapshot in commentSnapshots {
                        let commentData = commentSnapshot.data()
                        let comment = Comment(data: commentData)
                        comment.documentId = commentSnapshot.documentID
                        tweet.comments?.append(comment)
                    }
                }
                
                // リツイート情報取得
                self.db.collection("tweets").document(tweet.documentId!).collection("retweets").getDocuments { retweetSnapshots, err in
                    if let err = err {
                        print("コメント情報の取得失敗: \(err)")
                        return
                    }
                    
                    guard let retweetSnapshots = retweetSnapshots?.documents else { return }
                    for retweetSnapshot in retweetSnapshots {
                        let retweetData = retweetSnapshot.data()
                        let retweet = Retweet(data: retweetData)
                        retweet.documentId = retweetSnapshot.documentID
                        tweet.retweets?.append(retweet)
                    }
                }
                
                // いいね情報取得
                self.db.collection("tweets").document(tweet.documentId!).collection("likes").getDocuments { likeSnapshots, err in
                    if let err = err {
                        print("コメント情報の取得失敗: \(err)")
                        return
                    }
                    
                    guard let likeSnapshots = likeSnapshots?.documents else { return }
                    for likeSnapshot in likeSnapshots {
                        let likeData = likeSnapshot.data()
                        let like = Like(data: likeData)
                        like.documentId = likeSnapshot.documentID
                        tweet.likes?.append(like)
                    }
                }
                self.timelineTableView.reloadData()
            }
            
            
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
