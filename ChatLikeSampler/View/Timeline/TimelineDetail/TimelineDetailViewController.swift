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
    
    var db: Firestore!
    
    private let tebleViewContentInset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 90, right: 0)
    private let tableViewIndicatorInset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 90, right: 0)
    private var safeAreaBottom: CGFloat {
        self.view.safeAreaInsets.bottom
    }
    private let accessoryHeight: CGFloat = 100
    private lazy var commentInputAccessoryView: TimelineMessageInputAccessoryView = {
        let view = TimelineMessageInputAccessoryView()
        view.frame = .init(x: 0, y: 0, width: view.frame.width, height: accessoryHeight)
        view.delegate = self
        return view
    }()
    
    // messageInputAccessoryViewとキーボードを紐付け
    override var inputAccessoryView: UIView? {
        get {
            return commentInputAccessoryView
        }
    }
    // messageInputAccessoryViewがfirstResponderになれるよう設定
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @IBOutlet weak var timelineDetailTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupViews()
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
        db.collection("tweets").document(documentId).collection("comments").addDocument(data: sendData, completion: { err in
            if let err = err {
                print("コメント情報の保存に失敗しました: \(err)")
                return
            }
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
        self.commentInputAccessoryView.textViewDidEndEditing(commentInputAccessoryView.messageTextView)
    }

}

extension TimelineDetailViewController: TimelineMessageInputAccessoryViewDelegate {
    func tappedSendButton(text: String) {
        sendMessageToFirestore(text: text)
        commentInputAccessoryView.removeText()
        timelineDetailTableView.reloadData()
    }
}

