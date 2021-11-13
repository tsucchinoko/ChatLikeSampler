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
    
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var messageTextViewWithConstraint: NSLayoutConstraint!
        
    // messageに値がセットされたら呼ばれる
    var message: Message? {
        didSet {
            guard let message = message else { return }
            let width = estimateFrameForTextView(text: message.text).width + 20
            // テキストの長さにより、messageTextViewの幅を変化させる
            messageTextViewWithConstraint.constant = width
            messageTextView.text = message.text
            
            dateLabel.text = dateFormatterForDateLabel(date: message.created_at.dateValue())
            // 既読時はラベルを表示
            if message.read == true {
                self.readLabel.isHidden = false
            } else {
                self.readLabel.isHidden = true
            }
        }
    }
    
    
    // セルの初期化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        // アイコンを円にする
        messageTextView.layer.cornerRadius = 15
        readLabel.isHidden = true
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
    
    // 日付をフォーマットする
    private func dateFormatterForDateLabel(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        
        return formatter.string(from: date)
    }
}
