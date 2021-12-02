//
//  CommentDetailVC+CommentDetailCellDelegate.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/12/02.
//

import UIKit
import Firebase


// MARK: - CommentDetailCellDelegate
extension CommentDetailViewController: CommentDetailCellDelegate {
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
