//
//  MessageListViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/10/21.
//

import UIKit

class MessageListViewController: UIViewController {
    
    private let cellId = "cellId"
    
    @IBOutlet weak var messageListTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageListTableView.delegate = self
        messageListTableView.dataSource = self
        
        navigationController?.navigationBar.barTintColor =  UIColor.rgb(red: 39, green: 49, blue: 69)
        navigationItem.title = "トーク"
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        
        
    }
}

extension MessageListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = messageListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard.init(name: "MessageRoom", bundle: nil)
        // ストーリーボードIDを指定して画面遷移
        let messageVC = storyBoard.instantiateViewController(withIdentifier: "MessageRoomViewController")
        navigationController?.pushViewController(messageVC, animated: true)
    }
    
    
}

class MessageListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var latestMessageLabel: UILabel!
    @IBOutlet weak var partnerLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}




