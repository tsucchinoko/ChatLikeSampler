//
//  TimelineCell.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit
import Firebase

protocol TimelineCellDelegate {
    func didTappedCommentButton(cell: TimelineCell)
    func didTappedRetweetButton(cell: TimelineCell)
    func didTappedLikeButton(cell: TimelineCell)
    func didTappedFlagButton(cell: TimelineCell)
}

class TimelineCell: UITableViewCell {
    
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            messageTextView.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentNumberLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetNumberLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var flagButton: UIButton!
    
    var delegate: TimelineCellDelegate?
    
    var tweet: Tweet? {
        didSet {
            guard let tweet = tweet else { return }
            userNameLabel.text = tweet.creator
            dateLabel.text = dateFormatterForDateLabel(date: tweet.created_at?.dateValue() ?? Date())
            messageTextView.text = tweet.text
            
            let commentsNum = tweet.comments?.count ?? 0
            commentNumberLabel.text = String(commentsNum)
            
            let retweetsNum = tweet.retweets?.count ?? 0
            retweetNumberLabel.text = String(retweetsNum)
            
            let likesNum = tweet.likes?.count ?? 0
            likeNumberLabel.text = String(likesNum)
        }
    }
    
    // セルの初期化
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    // カスタムセルが選択されたことを検知
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // 日付をフォーマットする
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        
        return formatter.string(from: date)
    }
    
    @IBAction func didTappedCommentButton(_ sender: Any) {
        print(#function)
        delegate?.didTappedCommentButton(cell: self)

    }
    
    @IBAction func didTappedRetweetButton(_ sender: Any) {
        print(#function)
        delegate?.didTappedRetweetButton(cell: self)
    }
    
    @IBAction func didTappedLikeButton(_ sender: Any) {
        print(#function)
        delegate?.didTappedLikeButton(cell: self)
    }
    
    @IBAction func didTappedFlagButton(_ sender: Any) {
        print(#function)
        delegate?.didTappedFlagButton(cell: self)
    }
    
    
}
