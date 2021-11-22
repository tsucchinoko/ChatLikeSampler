//
//  TimelineDetailViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit
import Firebase

class TimelineDetailViewController: UIViewController {
    let timelineCellId = "timelineCell"
    let commentDetailCellId = "commentDetailCell"
    
    var tweet: Tweet?
    var comments = [Comment]()
    var likes = [Like]()
    var retweets = [Retweet]()
    
    @IBOutlet weak var timelineDetailTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchCommentInfoFromFirestore()
    }
    

    private func setupViews() {
        navigationController?.navigationBar.barTintColor =  UIColor.rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "タイムライン詳細画面"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        timelineDetailTableView.delegate = self
        timelineDetailTableView.dataSource = self
        // tableViewにセルを登録
        timelineDetailTableView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellReuseIdentifier: timelineCellId)
        timelineDetailTableView.register(UINib(nibName: "CommentDetailCell", bundle: nil), forCellReuseIdentifier: commentDetailCellId)
        
        // セルが見切れないように位置を微調整
//        timelineDetailTableView.contentInset = tebleViewContentInset
//        // スクロールバーの位置を微調整
//        timelineDetailTableView.scrollIndicatorInsets = tableViewIndicatorInset
        // スクロール時にキーボードを閉じる
        timelineDetailTableView.keyboardDismissMode = .interactive
    }
    
    // コメント情報の取得
    private func fetchCommentInfoFromFirestore(){
        guard let documentId = tweet?.documentId else { return }
        // Tweetを取得
        Firestore.firestore().collection("tweets").document(documentId).collection("comments").getDocuments { commentSnapshots, err in
            if let err = err {
                print("コメント情報の取得失敗: \(err)")
                return
            }
            
            guard let snapshots = commentSnapshots?.documents else { return }
            for snapshot in snapshots {
                let data = snapshot.data()
                let comment = Comment(data: data)
                comment.documentId = snapshot.documentID
                
                self.comments.append(comment)
            }
            self.timelineDetailTableView.reloadData()
        }
        
    }

}


extension TimelineDetailViewController: UITableViewDelegate, UITableViewDataSource {
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("#comments.count: \(comments.count)")
        return comments.count + 1
    }
    
    // カスタムセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = timelineDetailTableView.dequeueReusableCell(withIdentifier: timelineCellId, for: indexPath) as! TimelineCell
            cell.tweet = tweet
            return cell
        } else {
            let cell = timelineDetailTableView.dequeueReusableCell(withIdentifier: commentDetailCellId, for: indexPath) as! CommentDetailCell
            print("#indexPath.row: \(indexPath.row - 1)")
            cell.comment = comments[indexPath.row - 1]
            return cell
        }
        
    }
    
    // セル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard.init(name: "CommentDetailViewController", bundle: nil)
        // ストーリーボードIDを指定して画面遷移
        let timelineDetailVC = storyBoard.instantiateViewController(withIdentifier: "CommentDetailViewController") as! CommentDetailViewController

        
        navigationController?.pushViewController(timelineDetailVC, animated: true)
        timelineDetailTableView.deselectRow(at: indexPath, animated: true)
    }
}
