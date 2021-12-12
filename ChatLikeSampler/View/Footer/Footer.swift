//
//  FooterView.swift
//  CustomCellSampler
//
//  Created by Daichi Tsuchiya on 2021/10/08.
//

import UIKit

@IBDesignable
class FooterView: UIView {

    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var homeTabItem: UITabBarItem!

    @IBOutlet weak var messageTabItem: UITabBarItem!
    @IBOutlet weak var profileTabItem: UITabBarItem!
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.configureView()
    }
    
    private func configureView() {
        guard let view = self.loadViewFromNib(nibName: "FooterView") else { return }
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)
    }
    


}
