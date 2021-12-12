//
//  TimelineViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit
import Firebase
import Dispatch

class TimelineViewController: UIViewController {
    let cellId = "timelineCell"
    
    var tweets: [Tweet] = []
    var db: Firestore!
    
    @IBOutlet weak var timelineTableView: UITableView!
    
    // メインキューを取得
    let mainQueue = DispatchQueue.main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        setupViews()
        fetchTimelineInfoFromFirestore()
        refreshTableView()
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
//        let semaphore  = DispatchSemaphore(value: 1)
        
        // Tweetを取得
        db.collection("tweets").getDocuments { tweetsSnapshots, err in
            if let err = err {
                print("Tweet情報の取得失敗: \(err)")
                return
            }
            
            // Tweet情報を配列に格納
            guard let snapshots = tweetsSnapshots?.documents else { return }
            self.tweets = snapshots.map { document in
                let tweet = Tweet(document: document)
                tweet.comments = self.fetchCommentInfoFromFirestore(tweet: tweet)
                tweet.retweets = self.fetchRetweetInfoFromFireStore(tweet: tweet)
                tweet.likes = self.fetchLikeInfoFromFireStore(tweet: tweet)
                return tweet
            }
        }
        
        
    }
    
    private func fetchCommentInfoFromFirestore(tweet: Tweet) -> [Comment]? {
        
//        let semaphore  = DispatchSemaphore(value: 1)
        // コメント情報取得
            self.db.collection("tweets").document(tweet.documentId!).collection("comments").getDocuments { commentSnapshots, err in
                if let err = err {
                    print("コメント情報の取得失敗: \(err)")
                    return
                }
                
                guard let commentSnapshots = commentSnapshots?.documents else { return }
                tweet.comments = commentSnapshots.map { document in
                    let comment = Comment(document: document)
                    return comment
                }
//                semaphore.signal()
            }
//        semaphore.wait()
        return tweet.comments
    }
    
    private func fetchRetweetInfoFromFireStore(tweet: Tweet) -> [Retweet]? {
        // リツイート情報取得
        self.db.collection("tweets").document(tweet.documentId!).collection("retweets").getDocuments { retweetSnapshots, err in
            if let err = err {
                print("コメント情報の取得失敗: \(err)")
                return
            }
            
            guard let retweetSnapshots = retweetSnapshots?.documents else { return }
            tweet.retweets = retweetSnapshots.map { document in
                let retweet = Retweet(document: document)
                return retweet
            }
        }
        return tweet.retweets
    }
    
    private func fetchLikeInfoFromFireStore(tweet: Tweet) -> [Like]? {
        // いいね情報取得
        self.db.collection("tweets").document(tweet.documentId!).collection("likes").getDocuments { likeSnapshots, err in
            if let err = err {
                print("コメント情報の取得失敗: \(err)")
                return
            }
            
            guard let likeSnapshots = likeSnapshots?.documents else { return }
            tweet.likes = likeSnapshots.map { document in
                let like = Like(document: document)
                return like
            }
        }
        return tweet.likes
    }
    
    // tableViewを下に引っ張ったときにインジケーターを表示
    @objc func refreshTableView() {
        // 応急処置のため非同期処理用に修正
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.timelineTableView.reloadData()
            self.timelineTableView.refreshControl?.endRefreshing()
        }
    }
    
}
