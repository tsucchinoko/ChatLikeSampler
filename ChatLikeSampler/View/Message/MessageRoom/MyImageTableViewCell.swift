//
//  MyImageTableViewCell.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/13.
//

import UIKit

class MyImageTableViewCell: UITableViewCell {
    // セルの初期化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
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
