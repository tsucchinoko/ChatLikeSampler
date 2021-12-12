//
//  TimelineDetailVC+TimelineDetailCellDelegate.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/30.
//

import UIKit
import Firebase


// MARK: - TimelineCellDelegate
extension TimelineDetailViewController: TimelineCellDelegate {
    func didTappedCommentButton(cell: TimelineCell) {
        // TODO 選択されたセルのタイムライン詳細画面に画面遷移
    }

    func didTappedRetweetButton(cell: TimelineCell) {
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
        let backImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        cell.likeButton.setImage(backImage, for: .normal)
        cell.likeButton.tintColor = .systemPink

        // いいね数の更新
        var count = tweet?.likes?.count ?? 0
        count += 1
        cell.likeNumberLabel.text = String(count)
        // TODO 自分のいいねしたリストに追加
        
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
                    
                    guard let documentId = self.tweet?.documentId else { return }
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
        let backImage = UIImage(systemName: "flag.fill")?.withRenderingMode(.alwaysTemplate)
        cell.flagButton.setImage(backImage, for: .normal)
        cell.flagButton.tintColor = .red

        // TODO ポップアップ表示
        // TODO 報告処理
    }
}

extension TimelineDetailViewController: CommentDetailCellDelegate {
    func didTappedCommentButton(cell: CommentDetailCell) {
        // TODO 選択されたセルのタイムライン詳細画面に画面遷移
    }
    
    func didTappedRetweetButton(cell: CommentDetailCell) {
        let backImage = UIImage(systemName: "repeat")?.withRenderingMode(.alwaysTemplate)
        cell.retweetButton.setImage(backImage, for: .normal)
        cell.retweetButton.tintColor = .green
        
        // TODO リツイート数+1
        // TODO 自分の投稿に追加
    }
    
    func didTappedLikeButton(cell: CommentDetailCell) {
        let backImage = UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate)
        cell.likeButton.setImage(backImage, for: .normal)
        cell.likeButton.tintColor = .systemPink
        
        // TODO いいね数+1
        // TODO 自分のいいねしたリストに追加
    }
    
    func didTappedFlagButton(cell: CommentDetailCell) {
        let backImage = UIImage(systemName: "flag.fill")?.withRenderingMode(.alwaysTemplate)
        cell.flagButton.setImage(backImage, for: .normal)
        cell.flagButton.tintColor = .red
        
        // TODO ポップアップ表示
        // TODO 報告処理
    }
    
}

