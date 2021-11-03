//
//  MyMessageRoomTableViewCell.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/10/24.
//


import UIKit

class MyMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var messageTextViewWithConstraint: NSLayoutConstraint!
    
    var messageText: String? {
        didSet {
            guard let text = messageText else { return }
            let width = estimateFrameForTextView(text: text).width + 10
            
            // テキストの長さにより、messageTextViewの幅を変化させる
            messageTextViewWithConstraint.constant = width
            messageTextView.text = text
            
        }
    }
    
    
    // セルの初期化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        // アイコンを円にする
        messageTextView.layer.cornerRadius = 15
    }
    
    // カスタムセルが選択されたことを検知
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // テキストの幅を計算
    private func  estimateFrameForTextView(text: String) -> CGRect {
        let maxSize = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: maxSize, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
    }
}
