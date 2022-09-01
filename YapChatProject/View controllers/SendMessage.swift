//
//  SendMessageViewController.swift
//  YapChatProject
//
//  Created by Ahmad on 31/08/2022.
//

import UIKit
import SignalRSwift
import CoreData


struct Message {
    var id: Int
    var message: String
    var name: String
}


class SendMessageViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTxtField: UITextField!
    
    @IBOutlet weak var receiveBtn: UIButton!
    @IBOutlet weak var typingLbl: UILabel!
    var hubConnection: HubConnection!
    var chat: HubProxy!
    var user: Model?
    var userMessage: UserMessage?
    var detailOfVisitor: VisitorMessageDetails?
    var message: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTxtField.delegate = self
        view.backgroundColor = .yellow
        hubConnection = HubConnection(withUrl: "https://tlp.360scrm.com")
        chat = self.hubConnection.createHubProxy(hubName: "NotificationHub")
        
        _ = chat?.on(eventName:"￼￼broadcastMessage") { (args) in
             if let name = args[0] as? String, let id = args[1] as? Int, let message = args[2] as? String {
                        print("Name: \(name), VisitorID: \(id), message: \(message)")
                    }
         }
        chat.invoke(method: "JoinGroup", withArgs: ["Group1"]) { result, error in
            if let error = error {
                print(error)
            } else {
                print("invoked")
            }
        }
        
        detailsOfVisitorChat(visitorId: self.user?.id ?? 0, sessionId: self.user?.visitorSession.id ?? 1)
        
        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        receiveBtn.addTarget(self, action: #selector(receiveMessage), for: .touchUpInside)
    }
    
    func openHubConnection() {

        hubConnection.started = {
            self.typingLbl.text = "Connected"
        }

        hubConnection.reconnecting = {
            self.typingLbl.text = "Connected"
            print("Reconnecting...")
        }

        hubConnection.reconnected = {
            self.typingLbl.text = "Reconnected, connection ID: \(self.hubConnection.connectionId ?? " ")"
            print("Reconnected.")
        }

        hubConnection.closed = {
            self.typingLbl.text = "Hub Disconnected"
            print("Hub Disconnected")
        }

        hubConnection.connectionSlow = {
            self.typingLbl.text = "Connection Slow"
            print("Connection slow...") }

        hubConnection.error = { error in
            print(error)
        }

        hubConnection.start()
    }
    
    func saveVisitorChat(visitorSessionID: Int, visitorId: Int, message: String) {
        let parameters: [String : Any ] = [
            "WcVisitorSessionId": visitorSessionID,
            "wcVisitorId": visitorId,
            "message": message,
        ]
        ServiceManager.postApiCall(parameters: parameters, apiKey: ApiKey.saveVisitorChat) {(result : Result<UserMessage,Error>) in
            switch result {
            case .success(let response):
                print(response)
                self.userMessage = response
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func detailsOfVisitorChat(visitorId: Int, sessionId: Int) {
        
        let parameters: [String : Any ] = [
            "VisitorId": visitorId,
            "SessionId": sessionId,
        ]
        ServiceManager.postApiCall(parameters: parameters, apiKey: ApiKey.getDetailsOfVisitorChatSession) {(result : Result<VisitorMessageDetails,Error>) in
            switch result {
            case .success(let response):
                print(response)
                self.detailOfVisitor = response
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    @objc func sendMessage() {
        if let messageTxt = messageTxtField.text {

            print("User Id is \(self.user?.id ?? 0) and name is \(user?.name ?? " ")")
            chat.invoke(method: "brdcastMessage", withArgs: [self.user?.id, self.user?.name, messageTxt], completionHandler: { result, error in
                print("adfas")
            })
            self.saveVisitorChat(visitorSessionID: user?.visitorSession.id ?? 0, visitorId: user?.id ?? 1, message: messageTxt)
            
            message.append(messageTxt)
            print("Messages \(message)")
        }
    }
    
    @objc func receiveMessage() {
        print("is tapped.")
        _ = chat?.on(eventName:"￼￼broadcastMessage") { (args) in
             if let name = args[0] as? String, let id = args[1] as? Int, let message = args[2] as? String {
                        print("Name: \(name), VisitorID: \(id), message: \(message)")
                    }
         }
    }
}

extension SendMessageViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       // chat?.invoke(method: "visitorTyping", withArgs: [self.user?.id ?? 0,  self.user?.name ?? "Ahmed"])
        
        chat.invoke(method: "visitorTyping", withArgs: [self.user?.id ?? 0,  self.user?.name ?? "Ahmed"]) { response, error  in
            if let error = error {
                print(error)
            } else {
                print("\(self.user!.name) is typing..")
            }
        }
        return true
    }
}
