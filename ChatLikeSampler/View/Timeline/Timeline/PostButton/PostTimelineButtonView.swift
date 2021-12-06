//
//  PostTimelineButtonView.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/11/19.
//

import UIKit

class PostTimelineViewController: UIViewController {
    
    @IBOutlet weak var postViewButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews(){
        let width = postViewButton.frame.width
        postViewButton.layer.cornerRadius = width / 2
    }
    
    @IBAction func didTappedPostViewButton(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard.init(name: "PostModalViewController", bundle: nil)
        let postView = storyboard.instantiateViewController(withIdentifier: "PostModalViewController") as! PostModalViewController
        postView.modalPresentationStyle = .fullScreen
        self.present(postView, animated: true, completion: nil)
    }
    

}
