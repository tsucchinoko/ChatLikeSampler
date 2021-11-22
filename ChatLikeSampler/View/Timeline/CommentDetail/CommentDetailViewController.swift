//
//  CommentDetailViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit
import Firebase

class CommentDetailViewController: UIViewController {
    let timelineCellId = "timelineCell"
    let commentDetailCellId = "commentDetailCell"
    
    var selectedComment: Comment?
    var threadComments = [Comment]()
    var likes = [Like]()
    var retweets = [Retweet]()

    @IBOutlet weak var commentDetailTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    

    private func setupViews() {
        navigationController?.navigationBar.barTintColor =  UIColor.rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "コメント詳細画面"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        commentDetailTableView.delegate = self
        commentDetailTableView.dataSource = self
        // tableViewにセルを登録
        commentDetailTableView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellReuseIdentifier: timelineCellId)
        commentDetailTableView.register(UINib(nibName: "CommentDetailCell", bundle: nil), forCellReuseIdentifier: commentDetailCellId)
        
        // セルが見切れないように位置を微調整
//        commentDetailTableView.contentInset = tebleViewContentInset
//        // スクロールバーの位置を微調整
//        commentDetailTableView.scrollIndicatorInsets = tableViewIndicatorInset
        // スクロール時にキーボードを閉じる
        commentDetailTableView.keyboardDismissMode = .interactive
    }
    
    // スレッド内のコメント情報の取得
    private func fetchThreadCommentInfoFromFirestore(){
        guard let documentId = selectedComment?.documentId else { return }
        // Tweetを取得
        Firestore.firestore().collection("comments").document(documentId).collection("comment").getDocuments { commentSnapshots, err in
            if let err = err {
                print("コメント情報の取得失敗: \(err)")
                return
            }
            
            guard let snapshots = commentSnapshots?.documents else { return }
            for snapshot in snapshots {
                let data = snapshot.data()
                let threadComment = Comment(data: data)
                threadComment.documentId = snapshot.documentID
                
                self.threadComments.append(threadComment)
            }
            self.commentDetailTableView.reloadData()
        }
        
    }

}

extension CommentDetailViewController: UITableViewDelegate,UITableViewDataSource {
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threadComments.count + 1
    }
    
    // カスタムセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = commentDetailTableView.dequeueReusableCell(withIdentifier: commentDetailCellId, for: indexPath) as! CommentDetailCell
            cell.comment = selectedComment
            return cell
        } else {
            let cell = commentDetailTableView.dequeueReusableCell(withIdentifier: commentDetailCellId, for: indexPath) as! CommentDetailCell
            cell.comment = threadComments[indexPath.row - 1]
            return cell
        }
        
    }
    
    // セル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard.init(name: "CommentDetailViewController", bundle: nil)
        // ストーリーボードIDを指定して画面遷移
        let commentDetailVC = storyBoard.instantiateViewController(withIdentifier: "CommentDetailViewController") as! CommentDetailViewController
        
        if indexPath.row == 0 {
            commentDetailTableView.deselectRow(at: indexPath, animated: true)
            return
        } else {
            commentDetailVC.selectedComment = threadComments[indexPath.row - 1]
            navigationController?.pushViewController(commentDetailVC, animated: true)
            commentDetailTableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
