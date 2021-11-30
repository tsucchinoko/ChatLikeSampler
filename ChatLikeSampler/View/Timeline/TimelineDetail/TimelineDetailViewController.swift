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
    
    private let tebleViewContentInset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 90, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 90, right: 0)
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    private let accessoryHeight: CGFloat = 100
    private lazy var messageInputAccessoryView: TimelineMessageInputAccessoryView = {
        let view = TimelineMessageInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeight)
        view.delegate = self
        return view
    }()
    
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
        timelineDetailTableView.contentInset = tebleViewContentInset
        // スクロールバーの位置を微調整
        timelineDetailTableView.scrollIndicatorInsets = tableViewIndicatorInset
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
    
    // Firestoreにコメントを送信
    private func sendMessageToFirestore(text: String){
        // UID取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let sendTime = Timestamp()
        let sendData = [
            "profile_icon": "",
            "email": "",
            "username": "",
            "text": text,
            "is_deleted": false,
            "created_at": sendTime,
            "updated_at": sendTime,
        ] as [String : Any]
        
        // Firestoreにコメントを送信
        guard let documentId = tweet?.documentId else { return }
        Firestore.firestore().collection("tweets").document(documentId).collection("comments").addDocument(data: sendData, completion: { err in
            if let err = err {
                print("コメント情報の保存に失敗しました: \(err)")
                return
            }
            
            let comment = Comment(data: sendData)
            self.comments.append(comment)
            self.tweet?.comments?.append(comment)
            self.timelineDetailTableView.reloadData()
        })
    }
    
    // キーボード出現時
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
            
            if keyboardFrame.height <= accessoryHeight { return }
            
            // キーボードの高さ分messageRoomTableViewを上にずらす
            let buttom = keyboardFrame.height - safeAreaBottom
            let moveY = -buttom
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: buttom, right: 0)
            
            timelineDetailTableView.contentInset = contentInset
            timelineDetailTableView.scrollIndicatorInsets = contentInset
            timelineDetailTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    
    // キーボードが閉じたとき
    @objc func keyboardWillHide() {
        timelineDetailTableView.contentInset = tebleViewContentInset
        timelineDetailTableView.scrollIndicatorInsets = tableViewIndicatorInset
        
    }

    // キーボードを閉じる
    @objc func dismissKeyboard() {
        self.messageInputAccessoryView.textViewDidEndEditing(messageInputAccessoryView.messageTextView)
    }

}

extension TimelineDetailViewController: TimelineMessageInputAccessoryViewDelegate {
    func tappedSendButton(text: String) {
        sendMessageToFirestore(text: text)
        messageInputAccessoryView.removeText()
        timelineDetailTableView.reloadData()
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
            cell.delegate = self
            
            return cell
        } else {
            let cell = timelineDetailTableView.dequeueReusableCell(withIdentifier: commentDetailCellId, for: indexPath) as! CommentDetailCell
            cell.comment = comments[indexPath.row - 1]
            cell.delegate = self
            
            return cell
        }
        
    }
    
    // セル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard.init(name: "CommentDetailViewController", bundle: nil)
        // ストーリーボードIDを指定して画面遷移
        let commentDetailVC = storyBoard.instantiateViewController(withIdentifier: "CommentDetailViewController") as! CommentDetailViewController
        
        if indexPath.row == 0 {
            timelineDetailTableView.deselectRow(at: indexPath, animated: true)
            return
        } else {
            commentDetailVC.selectedComment = comments[indexPath.row - 1]
            navigationController?.pushViewController(commentDetailVC, animated: true)
            timelineDetailTableView.deselectRow(at: indexPath, animated: true)
        }
    }
}


extension TimelineDetailViewController: TimelineCellDelegate {
    func didTappedCommentButton(cell: TimelineCell) {
        print(#function)
        // TODO 選択されたセルのタイムライン詳細画面に画面遷移
    }

    func didTappedRetweetButton(cell: TimelineCell) {
        print(#function)
        let backImage = UIImage(systemName: "repeat")?.withRenderingMode(.alwaysTemplate)
        cell.retweetButton.setImage(backImage, for: .normal)
        cell.retweetButton.tintColor = .green

        // リツイート数の更新
        var count = tweet?.retweets?.count ?? 0
        count += 1
        cell.retweetNumberLabel.text = String(count)
        // TODO 自分の投稿に追加
    }

    func didTappedLikeButton(cell: TimelineCell) {
        print(#function)
        let backImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        cell.likeButton.setImage(backImage, for: .normal)
        cell.likeButton.tintColor = .systemPink

        // いいね数の更新
        var count = tweet?.likes?.count ?? 0
        count += 1
        cell.likeNumberLabel.text = String(count)
        // TODO 自分のいいねしたリストに追加
    }

    func didTappedFlagButton(cell: TimelineCell) {
        print(#function)
        let backImage = UIImage(systemName: "flag.fill")?.withRenderingMode(.alwaysTemplate)
        cell.flagButton.setImage(backImage, for: .normal)
        cell.flagButton.tintColor = .red

        // TODO ポップアップ表示
        // TODO 報告処理
    }
}

extension TimelineDetailViewController: CommentDetailCellDelegate {
    func didTappedCommentButton(cell: CommentDetailCell) {
        print(#function)
        // TODO 選択されたセルのタイムライン詳細画面に画面遷移
    }
    
    func didTappedRetweetButton(cell: CommentDetailCell) {
        print(#function)
        let backImage = UIImage(systemName: "repeat")?.withRenderingMode(.alwaysTemplate)
        cell.retweetButton.setImage(backImage, for: .normal)
        cell.retweetButton.tintColor = .green
        
        // TODO リツイート数+1
        // TODO 自分の投稿に追加
    }
    
    func didTappedLikeButton(cell: CommentDetailCell) {
        print(#function)
        print("########")
        let backImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        cell.likeButton.setImage(backImage, for: .normal)
        cell.likeButton.tintColor = .systemPink
        
        // TODO いいね数+1
        // TODO 自分のいいねしたリストに追加
    }
    
    func didTappedFlagButton(cell: CommentDetailCell) {
        print(#function)
        let backImage = UIImage(systemName: "flag.fill")?.withRenderingMode(.alwaysTemplate)
        cell.flagButton.setImage(backImage, for: .normal)
        cell.flagButton.tintColor = .red
        
        // TODO ポップアップ表示
        // TODO 報告処理
    }
    
}

