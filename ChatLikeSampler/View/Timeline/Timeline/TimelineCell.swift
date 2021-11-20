//
//  TimelineCell.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit

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
    @IBOutlet weak var feedTextView: UITextView! {
        didSet {
            feedTextView.isUserInteractionEnabled = false
        }
    }
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentNumberLabel: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetNumberLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumberLabel: UILabel!
    @IBOutlet weak var flagButton: UIButton!
    @IBOutlet weak var flagNumberLabel: UILabel!
    
    var delegate: TimelineCellDelegate?
    
    // セルの初期化
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    // カスタムセルが選択されたことを検知
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
