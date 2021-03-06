//
//  MainViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/09.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import Kingfisher

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var array: [UserModel] = []
    var tableView: UITableView!
    
    @objc func printTestItem() {
        print("clickckckckckck")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Custom navigation-bar
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Friends"
        label.textAlignment = .left
        navigationItem.titleView = label
        //        view.addSubview(label)
        if let navigationBar = navigationController?.navigationBar {
            
            label.leadingAnchor.constraint(equalTo: navigationBar.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
            label.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor, constant: 0).isActive = true
            //            label.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 0).isActive = true
            //            label.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0).isActive = true
            
            let searchFriendButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(printTestItem))
            let addFriendButton = UIBarButtonItem(image: UIImage(systemName: "person.badge.plus"), style: .plain, target: self, action: #selector(printTestItem))
            let playMusicButton = UIBarButtonItem(image: UIImage(systemName: "music.note"), style: .plain, target: self, action: #selector(printTestItem))
            let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(printTestItem))
            
            navigationItem.rightBarButtonItems = [settingButton, playMusicButton, addFriendButton, searchFriendButton]
            
        }
        
        // MARK: Make Friends-List
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FriendsViewTableCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (m) in
            m.top.equalTo(view)
            m.bottom.left.right.equalTo(view)
        }
        
        // MARK: Load Friends-List
        Database.database().reference().child("users").observe(DataEventType.value) { (snapshot) in
            
            self.array.removeAll()
            
            //            let myUid = Auth.auth().currentUser?.uid
            
            //MARK: Read user info
            for child in snapshot.children {
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                
                if let dicItem = fchild.value as? [String : Any]{
                    userModel.setValuesForKeys(dicItem)
                    //                    if userModel.uid != myUid {
                    self.array.append(userModel)
                    //                    }
                }
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData();
            }
        }
        
        // MARK: Make Group-Chat-Button
        let selectFriendButton = UIButton()
        view.addSubview(selectFriendButton)
        selectFriendButton.snp.makeConstraints { (m) in
            m.bottom.equalTo(view).offset(-90)
            m.right.equalTo(view).offset(-20)
            m.width.height.equalTo(50)
        }
        selectFriendButton.backgroundColor = UIColor.black
        selectFriendButton.addTarget(self, action: #selector(showSelectFriendController), for: .touchUpInside)
        selectFriendButton.layer.cornerRadius = 25
        selectFriendButton.layer.masksToBounds = true
        
    }
    
    @objc func showSelectFriendController() {
        self.performSegue(withIdentifier: "SelectFriendSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FriendsViewTableCell
        let imageView = cell.imageview!
        
        imageView.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(cell).offset(10)
            m.height.width.equalTo(50)
        }
        
        let url = URL(string: array[indexPath.row].profileImageURL!)
        imageView.layer.cornerRadius = 50/2 // imageView.frame.size.width/2 이거는 그려지기 전에 연산하기 때문에 정상적으로 출력이 안돼서 상수로 넣어줬다
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: url)
        //        URLSession.shared.dataTask(with: !) { (data, response, err) in
        //            DispatchQueue.main.async {
        //                imageView.image = UIImage(data: data!)
        //            }
        //
        //        }.resume()
        
        let label = cell.label!
        label.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(imageView.snp.right).offset(20)
        }
        
        label.text = array[indexPath.row].name
        
        let messageLabel = cell.messageLabel!
        messageLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(cell.messageBackgroundUIView) // 중간에 위치
            m.centerY.equalTo(cell)
        }
        if let message = array[indexPath.row].message {
            messageLabel.text = message
        }
        
        // 글씨 없으면 없애주고 있으면 만들어줌
        cell.messageBackgroundUIView.snp.makeConstraints { (m) in
            m.right.equalTo(cell).offset(-10)
            m.centerY.equalTo(cell)
            if let count =  messageLabel.text?.count {
                m.width.equalTo(count * 10) // 글자 하나 길이 10이라 가정
            } else {
                m.width.equalTo(0)
            }
            m.height.equalTo(30)
        }
        cell.messageBackgroundUIView.backgroundColor = UIColor.gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let myUid = Auth.auth().currentUser?.uid
        if self.array[indexPath.row].uid == myUid {
//            if let view = self.storyboard?.instantiateViewController(identifier: "ProfileViewController") as? ProfileViewController {
//                view.destinationUid = self.array[indexPath.row].uid
//                view.modalPresentationStyle = .fullScreen
//                self.present(view, animated: true, completion: nil)
//            }
            if let view = self.storyboard?.instantiateViewController(identifier: "ProfileTabBarController") as? ProfileTabBarController {
                view.destinationUid = self.array[indexPath.row].uid
                view.modalPresentationStyle = .fullScreen
                self.present(view, animated: true, completion: nil)
            }
        } else {
            if let view = self.storyboard?.instantiateViewController(identifier: "ChatroomViewController") as? ChatroomViewController {
                view.destinationUid = self.array[indexPath.row].uid
                self.navigationController?.pushViewController(view, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class FriendsViewTableCell: UITableViewCell {
    var imageview: UIImageView! = UIImageView()
    var label: UILabel! = UILabel()
    var messageLabel: UILabel! = UILabel()
    var messageBackgroundUIView: UIView = UIView();
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(imageview)
        self.addSubview(label)
        self.addSubview(messageBackgroundUIView) // 메시지 라벨 밑에 넣으면 라벨글씨를 덮어버림
        self.addSubview(messageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
