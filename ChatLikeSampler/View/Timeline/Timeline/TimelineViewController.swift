//
//  TimelineViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit

class TimelineViewController: UIViewController {
    let cellId = "timelineCell"

    @IBOutlet weak var timelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)

        setupViews()
    }
    
    private func setupViews() {
        navigationController?.navigationBar.barTintColor =  UIColor.rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "タイムライン画面"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        // tableViewにセルを登録
        timelineTableView.register(UINib(nibName: "TimelineCell", bundle: nil), forCellReuseIdentifier: cellId)
        
        // セルが見切れないように位置を微調整
//        timelineTableView.contentInset = tebleViewContentInset
//        // スクロールバーの位置を微調整
//        timelineTableView.scrollIndicatorInsets = tableViewIndicatorInset
        // スクロール時にキーボードを閉じる
        timelineTableView.keyboardDismissMode = .interactive
    }

}

extension TimelineViewController: UITableViewDelegate, UITableViewDataSource {
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
        let cell = timelineTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TimelineCell
        return cell
    }
    
    // セル選択時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard.init(name: "TimelineDetailViewController", bundle: nil)
        // ストーリーボードIDを指定して画面遷移
        let timelineDetailVC = storyBoard.instantiateViewController(withIdentifier: "TimelineDetailViewController") as! TimelineDetailViewController

        
        navigationController?.pushViewController(timelineDetailVC, animated: true)
        timelineTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
