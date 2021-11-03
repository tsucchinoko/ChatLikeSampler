//
//  MessageInputAccessoryView.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/10/21.
//

import UIKit

protocol MessageInputAccessoryViewDelegate: AnyObject {
    func tappedSendButton(text: String)
    func tappedFileAddButton()
}

class MessageInputAccessoryView: UIView, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var fileAddButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    weak var delegate: MessageInputAccessoryViewDelegate?
    
    // コードから生成したカスタムビューの初期化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
        setupViews()
        autoresizingMask = .flexibleHeight
    }
    
    // ストーリーボードから生成時
    required init?(coder: NSCoder) {
        fatalError("init(corder:) has not been implemented")
    }
    
    // カスタムビューの初期化
    private func nibInit() {
        let nib = UINib(nibName: "MessageInputAccessoryView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    
    // カスタムビューの設定
    private func setupViews(){
        messageTextView.layer.cornerRadius = 15
        messageTextView.layer.borderColor = UIColor.rgb(red: 230, green: 230, blue: 230).cgColor
        messageTextView.layer.borderWidth = 1
        
        messageTextView.text = ""
        messageTextView.delegate = self
        
        sendButton.layer.cornerRadius = 15
        sendButton.imageView?.contentMode = .scaleAspectFill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.contentVerticalAlignment = .fill
        sendButton.isEnabled = false
    }
    
    // テキストをリセット
    func removeText() {
        messageTextView.text = ""
        sendButton.isEnabled = false
    }
    
    //　テキストビューを可変にする
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    // ファイル追加ボタンを押下
    @IBAction func tappedFileAddButton(_ sender: Any) {
        delegate?.tappedFileAddButton()
    }
    

    // 送信ボタンを押下
    @IBAction func tappedSendButton(_ sender: Any) {
        guard let text = messageTextView.text else { return }
        delegate?.tappedSendButton(text: text)
        
    }
}

extension MessageInputAccessoryView: UITextViewDelegate {
    
    // textViewの文字列の変化を検知
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            sendButton.isEnabled = false
        } else {
            sendButton.isEnabled = true
        }
    }
}
