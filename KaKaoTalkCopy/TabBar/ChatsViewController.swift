//
//  ChatsViewController.swift
//  KaKaoTalkCopy
//
//  Created by dindon on 2020/06/18.
//  Copyright © 2020 Alphachip. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var uid: String!
    var chats: [ChatModel]! = []
    var keys: [String] = []
    var destinationUsers: [String] = [] //대화하려는 유저들의 uid를 넣어둠
    
    @objc func printTestItem() {
        print("clickckckckckck")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Chats"
        label.textAlignment = .left
        navigationItem.titleView = label
        //        view.addSubview(label)
        if let navigationBar = navigationController?.navigationBar {
            
            label.leadingAnchor.constraint(equalTo: navigationBar.layoutMarginsGuide.leadingAnchor, constant: 0).isActive = true
            label.centerYAnchor.constraint(equalTo: navigationBar.centerYAnchor, constant: 0).isActive = true
            //            label.topAnchor.constraint(equalTo: navigationBar.topAnchor, constant: 0).isActive = true
            //            label.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 0).isActive = true
            
            let searchFriendButton = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(printTestItem))
            let addFriendButton = UIBarButtonItem(image: UIImage(systemName: "plus.bubble"), style: .plain, target: self, action: #selector(printTestItem))
            let playMusicButton = UIBarButtonItem(image: UIImage(systemName: "music.note"), style: .plain, target: self, action: #selector(printTestItem))
            let settingButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(printTestItem))
            
            navigationItem.rightBarButtonItems = [settingButton, playMusicButton, addFriendButton, searchFriendButton]
            
        }
        
        self.uid = Auth.auth().currentUser?.uid
        self.getChatsList()
        
        
    }
    
    func getChatsList() {
        Database.database().reference().child("chats").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            self.chats.removeAll() //viewDidAppear() 때문에 갱신 됐을 때 데이터 쌓이지 않으려면 해줘야함
            for item in datasnapshot.children.allObjects as! [DataSnapshot] { // item: 각 방
                if let chatsdic = item.value as? [String:AnyObject] {
                    let chatModel = ChatModel(JSON: chatsdic)
                    self.keys.append(item.key)
                    self.chats.append(chatModel!)
                }
            }
            // MARK: 채팅 목록 테이블 뷰 업데이트
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "rowCell", for: indexPath) as! CustomCell
        
        var destinationUid: String?
        
        // MARK: 상대방 가져오기
        for item in chats[indexPath.row].users {
            if item.key != self.uid { // key에 나와 상대의 uid가 있음
                destinationUid = item.key
                destinationUsers.append(destinationUid!)
            }
        }
        
        Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: DataEventType.value) { (datasnapshot) in
            // destinationUid로 DB의 users 안에 있는 userName을 가져옴
            let userModel = UserModel()
            userModel.setValuesForKeys(datasnapshot.value as! [String:AnyObject]) //1차는 쉽게 담을 수 있지만 2차, 3차원은 wrapper 사용해야.
            
            cell.nameLabel.text = userModel.name
            let url = URL(string: userModel.profileImageURL!)
            
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.width/2
            cell.profileImageView.layer.masksToBounds = true //원형으로
            cell.profileImageView.kf.setImage(with: url)
            //            URLSession.shared.dataTask(with: url!) { (data, response, err) in
            //                // 스레드로 로딩. 지연되지 않도록함
            //                DispatchQueue.main.async {
            //                    cell.profileImageView.image = UIImage(data: data!)
            //
            //                }
            //            }.resume()
            
            if self.chats[indexPath.row].comments.keys.count == 0 { // 마지막 메시지 없을 때 읽어들이는 것 방지
                return
            }
            
            let lastMessageKey = self.chats[indexPath.row].comments.keys.sorted() { $0>$1 } // 오름차순. 내림차순은 부등호 반대로
            cell.messageLabel.text = self.chats[indexPath.row].comments[lastMessageKey[0]]?.message
            
            let unixTime = self.chats[indexPath.row].comments[lastMessageKey[0]]?.timestamp
            cell.timestampLabel.text = unixTime?.toDayTime
            
        }
        
        return cell
    }
    
    // 테이블 뷰를 클릭했을 때 생기는 이벤트
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // 클릭했을 때 깜빡이면서 클릭한 것이 다시 사라짐
        
        let destinationUid = self.destinationUsers[indexPath.row]
        print("count:\(self.destinationUsers[indexPath.row].count)")
        if self.destinationUsers[indexPath.row].count > 2 {
            let view = self.storyboard?.instantiateViewController(withIdentifier: "GroupChatroomViewController") as! GroupChatroomViewController
            view.destinationRoom = self.keys[indexPath.row]
            self.navigationController?.pushViewController(view, animated: true) // 화면이 밀리면서 넘어감
        } else {
            let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatroomViewController") as! ChatroomViewController
            view.destinationUid = destinationUid
            self.navigationController?.pushViewController(view, animated: true) // 화면이 밀리면서 넘어감
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 이미지 갱신을 위해
        viewDidLoad()
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

class CustomCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    
}
