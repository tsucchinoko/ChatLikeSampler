//
//  SearchUserViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/12/06.
//

import UIKit

class SearchUserViewController: UIViewController {
    @IBOutlet weak var userSearchBar: UISearchBar!
    
    @IBOutlet weak var preferenceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view.
    }
    
    private func setupViews(){
        userSearchBar.backgroundImage = UIImage()
    }
    

    @IBAction func didTappedPreferenceButton(_ sender: Any) {
    }
    
}
