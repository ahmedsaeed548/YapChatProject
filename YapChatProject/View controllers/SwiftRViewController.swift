//
//  SwiftRViewController.swift
//  YapChatProject
//
//  Created by Ahmad on 02/09/2022.
//

import UIKit
import SwiftR
import SignalRSwift

class SwiftRViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var typingLBl: UILabel!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var messageTxtField: UITextField!
    @IBOutlet weak var typingLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    var hubConnection: HubConnection!
    var chat: HubProxy!
    var name: String!
    var user: Model?
    var userMessage: UserMessage?
    var detailOfVisitor: VisitorMessageDetails?
    var message: String = ""
    let baseURL = "https://tlp.360scrm.com"
    
    let userId = UserDefaults.standard.integer(forKey: "visitorId")
    let sessionId = UserDefaults.standard.integer(forKey: "sessionId")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTxtField.delegate = self
        
        hubConnection = HubConnection(withUrl: "https://tlp.360scrm.com/")
        
        chat = self.hubConnection.createHubProxy(hubName: "notificationHub")
        
        openHubConnection()
        
        receiveMessage()
        
        print("\(userId), \(sessionId)")
        
        self.saveVisitor(name: "ios", email: "iostest@gmail.com", phoneNumber: "03344978228")
//        if userId != nil && sessionId != nil {
//            self.detailsOfVisitorChat(visitorId: self.userId, sessionId: self.sessionId)
//        } else {
//            self.saveVisitor(name: "ios", email: "iostest@gmail.com", phoneNumber: "03344978228")
//        }

        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    func openHubConnection() {
        
        hubConnection.started = {
            self.typingLbl.text = "Connected"
        }
        
        hubConnection.reconnecting = {
            self.typingLbl.text = "Reconnecting"
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
    
    
    @objc func sendMessage() {
        
        self.message = messageTxtField.text!
        self.saveVisitorChat(visitorSessionID: self.user?.visitorSession.id ?? 1, visitorId: self.user?.id ?? 0, message: message)
        if let text = self.chatTextView.text {
            self.chatTextView.text = "\(text)\n\n\(self.user!.name): \(self.message)"}
    }
    
    func receiveMessage() {
        hubConnection.received = { data in
            
            if let values = data as? [String: Any] {
                print("Method Name is: \(values[Types.method]!), Hubname: \(values[Types.hubName]!), messageReceived: \(values[Types.array]!)")
                
                if values[Types.method] as! String == MethodName.broadcastMessage {
                    
                    let array = values[Types.array] as? [Any]
                    if array?[1] as? Int == self.user?.id {
                        print("Message received \(array![2])")
                        if let text = self.chatTextView.text {
                            self.chatTextView.text = "\(text)\n\n\(array![0]): \(array![2])"}
                    }
                }
                
                if values[Types.method] as! String == MethodName.agentTypingAlert {
                    self.agentTyping(label: self.typingLBl, text: "Agent is typing..")
                } else {
                    self.agentTyping(label: self.typingLbl, text: " ")
                    print("")
                }
                
                if values[Types.method] as! String == MethodName.ImageFromAgent {
                    let imageArr = values[Types.array] as? [Any]
                    let imageURL = self.baseURL + imageArr?[2] as! String
                    print("\(self.baseURL)\(imageArr![2])")
                }
            }
        }
    }
    
    func broadcastMessage(messages: [String]) {
        print("Message Received \(messages[2])")
    }
    
    func saveVisitor(name: String, email: String, phoneNumber: String) {
        
        let parameters: [String : Any ] = [
            "name": name,
            "email": email,
            "PhoneNumber": phoneNumber,
        ]
        
        ServiceManager.postApiCall(parameters: parameters, apiKey: ApiKey.saveVisitor) {(result : Result<User,Error>) in
            switch result {
            case .success(let response):
                print("response is \(response)")
                self.user = response.model
                UserDefaults.standard.set(self.user?.id, forKey: "visitorId")
                UserDefaults.standard.set(self.user?.visitorSession.id, forKey: "sessionId")
            case .failure(let failure):
                print(failure)
            }
        }
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
    
    func visitorTyping() {
        chat.invoke(method: "visitorTyping", withArgs: [self.user?.id ?? 0,  self.user?.name ?? "Ahmed"]) { response, error  in
            if let error = error {
                print(error)
            } else {
                print("\(self.user!.name) is typing..")
            }
        }
    }
    
    func agentTyping(label: UILabel, text: String) {
        label.text = text
    }
}

extension SwiftRViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.visitorTyping()
        return true
    }
}
