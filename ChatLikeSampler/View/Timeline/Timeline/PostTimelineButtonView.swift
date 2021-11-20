//
//  PostTimelineButtonView.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit

class PostTimelineButtonView: UIView {
    // コードから生成したカスタムビューの初期化
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nibInit()
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

}
