//
//  ChatViewController.swift
//  VideoChatApp
//
//  Created by Nilesh on 08/09/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

import UIKit



class ChatViewController: UIViewController,ChatEvents,UITableViewDataSource {

    @IBOutlet weak var messageTextView: UITextField!
    @IBOutlet weak var chatsTableView: UITableView!
    @IBOutlet weak var notificationView: UILabel!
    
    var nickName : String?
    
    var chatMessages = [[String:Any]]()
    let socketIOManager = SocketIOManager(urlString: "http://localhost:3000/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nickName ?? ""
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        socketIOManager.addEventListner(listner: self)
        
        socketIOManager.connectUserWithNickName(nickName: nickName ?? "") { (userList) in
            debugPrint(userList)
        }
        

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        socketIOManager.disconnectUser(nickName: nickName ?? "")
        socketIOManager.removeListner(listner: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func sendMessageButtonTapped(_ sender: Any) {
        socketIOManager.sendMessage(message: messageTextView.text ?? "")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UITableViewCellDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : ChatTableViewCell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatTableViewCell
        
        let message = self.chatMessages[indexPath.row]
        cell.configureViewWithMessage(message: message)
        
        return cell
        
    }
    
    
    // MARK: ChatEvents
    func newUserAdded(userInfo: [String : Any]) {
        
        if let userName = userInfo["nickname"] as? String {
            notificationView.text = ""+userName+" joined now"
        }
    }
    
    func receivedAllChats(chats: [[String : Any]]) {
        debugPrint("Received All chats")
        debugPrint(chats)
        
        chatMessages.removeAll()
        chatMessages = chats
        chatsTableView.reloadData()
    }
    
    func receivedNewChat(chatMessage: [String : Any]) {
        debugPrint("Received chat")
        debugPrint(chatMessage)
        chatMessages.append(chatMessage)
        
        chatsTableView.beginUpdates()
        
        let indexPath:IndexPath = IndexPath(row:(self.chatMessages.count - 1), section:0)
        
        chatsTableView.insertRows(at: [indexPath], with: .bottom)
        chatsTableView.endUpdates()
        chatsTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func userLeft(userInfo: [String : Any]) {
        if let userName = userInfo["nickname"] as? String {
            notificationView.text = ""+userName+" left the game"
        }
    }
}
