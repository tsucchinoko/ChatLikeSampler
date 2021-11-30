//
//  TimelineDetailVC+TableViewDelegate.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/30.
//

import UIKit
import Firebase

// MARK: - UITableViewDelegate
extension TimelineDetailViewController: UITableViewDelegate, UITableViewDataSource {
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 高さ(min)を設定
        timelineDetailTableView.estimatedRowHeight = 20
        // テキストビューの高さによってセルの高さを自動で変化させる
        return UITableView.automaticDimension
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


