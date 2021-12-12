//
//  TimelineVC+TableViewDelegate.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/30.
//

import UIKit
import Firebase

// MARK: - UITableViewDelegate
extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 高さ(min)を設定
        timelineTableView.estimatedRowHeight = 20
        // テキストビューの高さによってセルの高さを自動で変化させる
        return UITableView.automaticDimension
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    // カスタムセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = timelineTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TimelineCell
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        print("### cell.tweet = tweets[indexPath.row] ###")
        print("#tweets[indexPath.row].likes: \(tweets[indexPath.row].likes!)")
        // tagを追加し、どのセルのボタンか判別
        cell.tag = indexPath.row
        
        return cell
    }
    
    // セル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard.init(name: "TimelineDetailViewController", bundle: nil)
        // ストーリーボードIDを指定して画面遷移
        let timelineDetailVC = storyBoard.instantiateViewController(withIdentifier: "TimelineDetailViewController") as! TimelineDetailViewController
        timelineDetailVC.tweet = tweets[indexPath.row]
        
        
        navigationController?.pushViewController(timelineDetailVC, animated: true)
        timelineTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}



