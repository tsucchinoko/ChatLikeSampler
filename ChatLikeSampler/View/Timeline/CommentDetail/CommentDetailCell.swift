//
//  CommentDetailCell.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit

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
    
    var comment: Comment? {
        didSet {
            guard let comment = comment else { return }
            userNameLabel.text = comment.username
            dateLabel.text = dateFormatterForDateLabel(date: comment.created_at.dateValue())
            messageTextView.text = comment.text
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
}
