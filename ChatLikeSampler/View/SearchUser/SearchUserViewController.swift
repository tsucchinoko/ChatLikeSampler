//
//  SearchUserViewController.swift
//  ChatLikeSampler
//
//  Created by Daichi Tsuchiya on 2021/12/06.
//

import UIKit
import Firebase


class SearchUserViewController: UIViewController {
    
    private let cellId = "userListCellId"
    private var users = [User]()
    var db: Firestore!
    
    let mainQueue = DispatchQueue.main
    
    @IBOutlet weak var userSearchBar: UISearchBar!
    
    @IBOutlet weak var preferenceButton: UIButton!
    
    @IBOutlet weak var userListTableView: UITableView!
    
    @IBOutlet weak var desiredIndustryPicker: UIPickerView!
    
    @IBOutlet weak var desiredOccupationPicker: UIPickerView!
    
    @IBOutlet weak var desiredAreaPicker: UIPickerView!
    
    var dataList = [[String]]()
    var combination = [String]()
    var selectedIndustry = "未選択"
    var selectedOccupation = "未選択"
    var selectedArea = "未選択"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupViews(){
        userSearchBar.backgroundImage = UIImage()
        userSearchBar.delegate = self
        userListTableView.tableFooterView = UIView()
        userListTableView.delegate = self
        userListTableView.dataSource = self
        
        for _ in 0 ... 2 {
            dataList.append([])
        }
        
        desiredIndustryPicker.tag = 0
        desiredOccupationPicker.tag = 1
        desiredAreaPicker.tag = 2
        
        dataList[0] = ["未選択", "IT","広告","金融","保険"]
        dataList[1] = ["未選択", "エンジニア","ITコンサル","銀行員", "FP"]
        dataList[2] = ["未選択", "関東","東北","関西"]
        
        combination = ["未選択", "未選択", "未選択"]
        
        
        desiredIndustryPicker.delegate = self
        desiredIndustryPicker.dataSource =  self
        desiredOccupationPicker.delegate = self
        desiredOccupationPicker.dataSource = self
        desiredAreaPicker.delegate = self
        desiredAreaPicker.dataSource = self
        
    }
    
    // ユーザー検索
    private func fetchUserInfoFromFirestore(text: String, industry: String, occupation: String, area: String){
        self.users.removeAll()
//        var userList = []
        db.collection("users").order(by: "username").start(at: [text]).end(at: [text + "\u{f8ff}"]).whereField("desired_industry", arrayContainsAny: ["未選択", industry]).getDocuments { userSnapshots, err in
            if let err = err {
                print("ユーザー情報の取得に失敗しました: \(err)")
                return
            }
            
            if text == "" && industry == "未選択" { return }
            // Tweet情報を配列に格納
            guard let snapshots = userSnapshots?.documents else { return }
            self.users = snapshots.map { document in
                let user = User(document: document)
                print("##user!!: \(user)")
                return user
            }
        }
        
        db.collection("users").order(by: "username").start(at: [text]).end(at: [text + "\u{f8ff}"]).whereField("desired_occupation", arrayContainsAny: ["未選択", occupation]).getDocuments { userSnapshots, err in
            if let err = err {
                print("ユーザー情報の取得に失敗しました: \(err)")
                return
            }
            
            if text == "" && occupation == "未選択" { return }
            // Tweet情報を配列に格納
            guard let snapshots = userSnapshots?.documents else { return }
            self.users = snapshots.map { document in
                let user = User(document: document)
                print("##user!!: \(user)")
                return user
            }
        }
        
        db.collection("users").order(by: "username").start(at: [text]).end(at: [text + "\u{f8ff}"]).whereField("desired_area", arrayContainsAny: ["未選択", area]).getDocuments { userSnapshots, err in
            if let err = err {
                print("ユーザー情報の取得に失敗しました: \(err)")
                return
            }
            
            if text == "" && area == "未選択" { return }
            // Tweet情報を配列に格納
            guard let snapshots = userSnapshots?.documents else { return }
            self.users = snapshots.map { document in
                let user = User(document: document)
                print("##user!!: \(user)")
                return user
            }
        }
    }
    
    
    @IBAction func didTappedPreferenceButton(_ sender: Any) {
    }
    
    
    func refreshTableView() {
        // 応急処置のため非同期処理用に修正
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.userListTableView.reloadData()
        }
    }
}

extension SearchUserViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、要素の全数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        print("dataList.count: \(dataList.count)")
        return dataList[pickerView.tag].count
    }
    
    // UIPickerViewに表示する配列
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return dataList[pickerView.tag][row]
    }
    
    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {
        combination[pickerView.tag] = dataList[pickerView.tag][row]
        selectedIndustry = combination[0]
        selectedOccupation = combination[1]
        selectedArea = combination[2]
        print("combination: \(combination)")
    }
    
    // picker内のテキストサイズを調整
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()
        label.text = self.dataList[pickerView.tag][row]
        label.textAlignment = .center
        // テキストが長い場合に見きれないようにする
        label.adjustsFontSizeToFitWidth = true
        return label
    }
    
    
}

extension SearchUserViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetchUserInfoFromFirestore(text: searchText, industry: selectedIndustry, occupation: selectedOccupation, area: selectedArea)
        refreshTableView()
    }
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    
    // セルの高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //        userListTableView.estimatedRowHeight = 100
        // テキストビューの高さによってセルの高さを自動で変化させる
        //        return UITableView.automaticDimension
        return 80
    }
    // セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    // カスタムセルを設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = userListTableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserListTableViewCell
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userListTableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}



class UserListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var userAboutTextView: UITextView! {
        didSet {
            userAboutTextView.isUserInteractionEnabled = false
        }
    }
    
    var user: User? {
        didSet {
            if let user = user {
                //                TODO String -> UIImage
                //                userImageView.image = UIImage(user.profile_icon)
                userNameLabel.text = user.username
                userAboutTextView.text = user.about
                
                //                dateLabel.text = dateFormatterForDateLabel(date: room.latestMessage?.created_at.dateValue() ?? Date())
            }
        }
    }
    
    
    
    // カスタムセルを初期化
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
    }
    
    // カスタムセル選択時
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
