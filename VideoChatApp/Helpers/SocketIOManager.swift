//
//  SocketIOManager.swift
//  VideoChatApp
//
//  Created by Nilesh on 08/09/18.
//  Copyright © 2018 Nilesh. All rights reserved.
//

import UIKit
import SocketIO

protocol ChatEvents : NSObjectProtocol {
    
    func newUserAdded(userInfo:[String:Any])
    func receivedAllChats(chats:[[String:Any]])
    func receivedNewChat(chatMessage: [String:Any])
    func userLeft(userInfo:[String:Any])
}

enum SocketEvents : String {
    case AddNewUser = "connectUser"
    case UserList = "userList"
    case UserJoined = "userConnectUpdate"
    case sendNewMessage = "sendNewMessage"
    case receiveNewMessage = "newMessageBroadcast"
    case allChats = "chats"
    case getAllChats = "allChats"
    case leaveRoom = "disconnectUser"
    case userLeft = "userLeft"
}

class SocketIOManager: NSObject {
    var socketManager : SocketManager
    var socket : SocketIOClient
    var nickName : String?
    private var eventListners = [ChatEvents]()
    
    init(urlString : String ) {
        socketManager = SocketManager(socketURL: URL(string: urlString)!, config: [.log(true), .compress])
        socket = socketManager.defaultSocket
        
        super.init()
        
    }
    
    deinit {
        self.disconnectSocket()
    }
    
    func connectToSocket(userConnected: @escaping (Bool) -> Void) {
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            userConnected(true)
        }
        
        socket.connect()
    }
    
    func connectUserWithNickName(nickName: String, userList: @escaping ([[String:Any]]) -> Void) {
        
        self.connectToSocket { (connected) in
            if connected {
                self.socket.emit(SocketEvents.AddNewUser.rawValue, nickName)
                
                self.socket.on(SocketEvents.UserList.rawValue) { (data, ack) in
                    if let data = data[0] as? [[String: Any]] {
                        userList(data)
                    }
                }
                self.nickName = nickName
                self.listenForEvents()
            }
        }
    }
    
    func disconnectUser(nickName: String) {
        socket.emit(SocketEvents.leaveRoom.rawValue, nickName)
        socket.disconnect()
    }
    
    func sendMessage(message: String) {
        
        let textMessage = ["nickName": self.nickName ?? "", "message": message]
        socket.emit(SocketEvents.sendNewMessage.rawValue, textMessage)
    }
    
    func fetchAllChats() {
        socket.emit(SocketEvents.getAllChats.rawValue, "")
    }
    
    func listenForEvents() {
        
        socket.on(SocketEvents.UserJoined.rawValue) { (data, ack) in
            for listener in self.eventListners {
                if let data = data[0] as? [String: Any] {
                    listener.newUserAdded(userInfo: data )
                }
            }
        }
        
        socket.on(SocketEvents.allChats.rawValue) { (data, ack) in
            for listener in self.eventListners {
                if let data = data[0] as? [[String: Any]] {
                    listener.receivedAllChats(chats: data)
                }
            }
        }
        
        socket.on(SocketEvents.receiveNewMessage.rawValue) { (data, ack) in
            for listener in self.eventListners {
                if let data = data[0] as? [String: Any] {
                    listener.receivedNewChat(chatMessage: data)
                }
            }
        }
        
        socket.on(SocketEvents.userLeft.rawValue) { (data, ack) in
            for listener in self.eventListners {
                if let data = data[0] as? [String: Any] {
                    listener.userLeft(userInfo: data)
                }
            }
        }

    }
    
    func disconnectSocket() {
        socket.disconnect()
    }
    
    // MARK: Event Listners
    
    func addEventListner(listner: ChatEvents) {
        
        eventListners.append(listner)
    }
    
    func removeListner(listner: ChatEvents) {
        var index = NSNotFound
        for i in 0...eventListners.count {
            if let eventListener = eventListners[i] as? NSObject {
                if let l = listner as? NSObject {
                    if l == eventListener {
                        index = i
                        break
                    }
                }
            }
        }
        
        eventListners.remove(at: index)
    }
}
