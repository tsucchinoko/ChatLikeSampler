//
//  CommentDetailCell.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit


protocol CommentDetailCellDelegate {
    func didTappedCommentButton(cell: CommentDetailCell)
    func didTappedRetweetButton(cell: CommentDetailCell)
    func didTappedLikeButton(cell: CommentDetailCell)
    func didTappedFlagButton(cell: CommentDetailCell)
}

class CommentDetailCell: UITableViewCell {
    
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
    
    var delegate: CommentDetailCellDelegate?
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            userNameLabel.text = comment.username
            dateLabel.text = dateFormatterForDateLabel(date: comment.created_at?.dateValue() ?? Date())
            messageTextView.text = comment.text
            
            let commentsNum = comment.comments?.count ?? 0
            commentNumberLabel.text = String(commentsNum)

            let retweetsNum = comment.retweets?.count ?? 0
            retweetNumberLabel.text = String(retweetsNum)

            let likesNum = comment.likes?.count ?? 0
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
        delegate?.didTappedCommentButton(cell: self)
    }
    
    @IBAction func didTapedRetweetButton(_ sender: Any) {
        delegate?.didTappedRetweetButton(cell: self)
    }
    
    
    @IBAction func didTappedLikeButton(_ sender: Any) {
        delegate?.didTappedLikeButton(cell: self)
    }
    
    
    @IBAction func didTappedFlagButton(_ sender: Any) {
        delegate?.didTappedFlagButton(cell: self)
    }
}
