//
//  TimelineVC+TimelineCellDelegate.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/30.
//
import UIKit
import Firebase

// MARK: - TimelineCellDelegate
extension TimelineViewController: TimelineCellDelegate {
    
    // コメントボタン押下時
    func didTappedCommentButton(cell: TimelineCell) {
        print(#function)
        // ストーリーボードIDを指定して画面遷移
        let storyBoard = UIStoryboard.init(name: "TimelineDetailViewController", bundle: nil)
        let timelineDetailVC = storyBoard.instantiateViewController(withIdentifier: "TimelineDetailViewController") as! TimelineDetailViewController
        timelineDetailVC.tweet = tweets[cell.tag]
        navigationController?.pushViewController(timelineDetailVC, animated: true)
    }
    
    // リツイートボタン押下時
    func didTappedRetweetButton(cell: TimelineCell) {
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
                if snapshot.documentID == uid {
                    let userInfo = User(document: snapshot)
                    let likeTime = Timestamp()
                    let retweetData = [
                        "profile_icon": userInfo.profile_icon!,
                        "email": userInfo.email!,
                        "username": userInfo.username!,
                        "about": userInfo.about!,
                        "created_at": likeTime,
                        "updated_at": likeTime
                    ] as [String: Any]
                    
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
    
    // いいねボタン押下時
    func didTappedLikeButton(cell: TimelineCell) {
        let backImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        cell.likeButton.setImage(backImage, for: .normal)
        cell.likeButton.tintColor = .systemPink
        
        // いいね数の更新
        var count = tweets[cell.tag].likes?.count ?? 0
        count += 1
        cell.likeNumberLabel.text = String(count)
        
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
                if snapshot.documentID == uid {
                    let userInfo = User(document: snapshot)
                    let likeTime = Timestamp()
                    let likeData = [
                        "profile_icon": userInfo.profile_icon!,
                        "email": userInfo.email!,
                        "username": userInfo.username!,
                        "about": userInfo.about!,
                        "created_at": likeTime,
                        "updated_at": likeTime
                    ] as [String: Any]
                    
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
    
    // フラグボタン押下時
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

