//
//  CommentDetailViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit

class CommentDetailViewController: UIViewController {
    let timelineCellId = "timelineCell"
    let commentDetailCellId = "commentDetailCell"

    @IBOutlet weak var commentDetailTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
    

    private func setupViews() {
        navigationController?.navigationBar.barTintColor =  UIColor.rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "コメント詳細画面"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
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

}

extension CommentDetailViewController: UITableViewDelegate,UITableViewDataSource {
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 330
    }
    
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    // カスタムセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentDetailTableView.dequeueReusableCell(withIdentifier: commentDetailCellId, for: indexPath) as! CommentDetailCell
        return cell
    }
    
    // セル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let storyBoard = UIStoryboard.init(name: "TimelineDetailViewController", bundle: nil)
//        // ストーリーボードIDを指定して画面遷移
//        let timelineDetailVC = storyBoard.instantiateViewController(withIdentifier: "TimelineDetailViewController") as! TimelineDetailViewController
//
//
//        navigationController?.pushViewController(timelineDetailVC, animated: true)
    }
}
