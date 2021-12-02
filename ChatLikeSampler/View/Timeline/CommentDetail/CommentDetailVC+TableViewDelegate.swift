//
//  CommentDetailVC+TableViewDelegate.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/12/02.
//

import UIKit
import Firebase

// MARK: - UITableViewDelegate
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
            cell.delegate = self

            return cell
        } else {
            let cell = commentDetailTableView.dequeueReusableCell(withIdentifier: commentDetailCellId, for: indexPath) as! CommentDetailCell
            cell.comment = threadComments[indexPath.row - 1]
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
            commentDetailTableView.deselectRow(at: indexPath, animated: true)
            return
        } else {
            commentDetailVC.selectedComment = threadComments[indexPath.row - 1]
            navigationController?.pushViewController(commentDetailVC, animated: true)
            commentDetailTableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

