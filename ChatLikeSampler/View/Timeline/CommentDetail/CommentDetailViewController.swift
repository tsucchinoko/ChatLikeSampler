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
//        guard let documentId = selectedComment?.documentId else { return }
//        // Tweetを取得
//        Firestore.firestore().collection("comments").document(documentId).collection("comment").getDocuments { commentSnapshots, err in
//            if let err = err {
//                print("コメント情報の取得失敗: \(err)")
//                return
//            }
//            
//            guard let snapshots = commentSnapshots?.documents else { return }
//            for snapshot in snapshots {
//                let data = snapshot.data()
//                let threadComment = Comment(data: data)
//                threadComment.documentId = snapshot.documentID
//                
//                self.threadComments.append(threadComment)
//            }
//            self.commentDetailTableView.reloadData()
//        }
        
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
        guard let documentId = selectedComment?.documentId else { return }
        Firestore.firestore().collection("tweets").document(documentId).collection("comments").addDocument(data: sendData, completion: { err in
            if let err = err {
                print("コメント情報の保存に失敗しました: \(err)")
                return
            }
            
//            let comment = Comment(data: sendData)
//            self.threadComments.append(comment)
//            self.selectedComment?.comments?.append(comment)
//            self.commentDetailTableView.reloadData()
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
            
            commentDetailTableView.contentInset = contentInset
            commentDetailTableView.scrollIndicatorInsets = contentInset
            commentDetailTableView.contentOffset = CGPoint(x: 0, y: moveY)
        }
    }
    
    // キーボードが閉じたとき
    @objc func keyboardWillHide() {
        commentDetailTableView.contentInset = tebleViewContentInset
        commentDetailTableView.scrollIndicatorInsets = tableViewIndicatorInset
        
    }

    // キーボードを閉じる
    @objc func dismissKeyboard() {
        self.messageInputAccessoryView.textViewDidEndEditing(messageInputAccessoryView.messageTextView)
    }

}

extension CommentDetailViewController: TimelineMessageInputAccessoryViewDelegate {
    func tappedSendButton(text: String) {
        sendMessageToFirestore(text: text)
        messageInputAccessoryView.removeText()
        commentDetailTableView.reloadData()
    }
}

