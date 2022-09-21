//
//  Chat.swift
//  YapChatProject
//
//  Created by Ahmad on 13/09/2022.
//

import Foundation
import UIKit
import SignalRSwift

protocol ChatDelegate: AnyObject {
    func receiveMessage(message: String)
    func receiveImage(imagePath: String)
    func fetchPreviousMessages(messages: [WebChatDetialVisitor])
}

public class Chat {
    
    private var hubConnection : HubConnection!
    private var chatHub : HubProxy!
    var user : Model?
    var userMessage : UserMessage?
    var detailOfVisitor : VisitorMessageDetails?
    private var baseURL = "https://tlp.360scrm.com"
    private var userId = UserDefaults.standard.integer(forKey: "visitorId")
    private var sessionId = UserDefaults.standard.integer(forKey: "sessionId")
    var messages: [String] = [String]()
    var previousMessages: [WebChatDetialVisitor]?
    var delegate: ChatDelegate?
    
    @IBOutlet weak var typingLBl: UILabel!
    
    public func createConnection(key: String) {
        
        if key == "123" {
            self.hubConnection = HubConnection(withUrl: "https://tlp.360scrm.com")
            self.chatHub = self.hubConnection.createHubProxy(hubName: "NotificationHub")
            
            hubConnection.started = { print("Connected to the server.") }
            
            hubConnection.reconnecting = { print("Reconnecting...") }
            
            hubConnection.reconnected = {  print("Reconnected.")   }
            
            hubConnection.connectionSlow = { print("Connection slow...") }
            
            hubConnection.error = { error in
                print(error)
            }
            hubConnection.start()
        } else {
            print("Please enter correct key")
        }
        
    }
    
    public func openConnection(name: String, email: String, phoneNumber: String) {
        
        if self.userId != 0 && self.sessionId != 0 {
            self.detailsOfVisitorChat(visitorId: self.userId, sessionId: self.sessionId)
        } else {
            self.saveVisitor(name: name, email: email, phoneNumber: phoneNumber)
        }
    }
    
   public func printUserDefaultValues() {
        print("\(self.userId), \(self.sessionId)")
    }
    
    public func saveVisitor(name: String, email: String, phoneNumber: String) {
            
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
                    self.userId = response.model.id
                    self.sessionId = response.model.visitorSession.id ?? 0
                    UserDefaults.standard.set(self.user?.id, forKey: "visitorId")
                    UserDefaults.standard.set(self.user?.visitorSession.id, forKey: "sessionId")
                case .failure(let failure):
                    print(failure)
                }
            }
    }
    
    public func sendMessage(message: String) {
        
        let parameters: [String : Any ] = [
            "WcVisitorSessionId": self.sessionId,
            "wcVisitorId": self.userId,
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
        self.printUserDefaultValues()
    }

    
    public func detailsOfVisitorChat(visitorId: Int, sessionId: Int) {
        
        let parameters: [String : Any ] = [
            "VisitorId": visitorId,
            "SessionId": sessionId,
        ]
        ServiceManager.postApiCall(parameters: parameters, apiKey: ApiKey.getDetailsOfVisitorChatSession) {(result : Result<VisitorMessageDetails,Error>) in
            switch result {
            case .success(let response):
                print(response)
                self.detailOfVisitor = response
                self.previousMessages = response.webChatDetialVisitor ?? []
                self.delegate?.fetchPreviousMessages(messages: self.previousMessages ?? [])
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    public func visitorTyping() {
        chatHub.invoke(method: "visitorTyping", withArgs: [self.userMessage?.wcVisitorID ?? 0,  self.userMessage?.fromName ?? ""]) { response, error  in
            if let error = error {
                print(error)
            } else {
                print("Method invoked.")
            }
        }
    }
    
    public func agentTyping(label: UILabel, text: String) {
        label.text = text
    }

    
   public func receiveData() {
        hubConnection.received = { data in
            
            if let values = data as? [String: Any] {
                print("Method Name is: \(values[Types.method]!), Hubname: \(values[Types.hubName]!), Array: \(values[Types.array]!)")
                
                if values[Types.method] as! String == MethodName.broadcastMessage {
                    
                    let array = values[Types.array] as? [Any]
                    if array?[1] as? Int == self.userId {
                        let message = array?[2] as! String
                        print("Message received in hubconnection: \(message)")
                        self.delegate?.receiveMessage(message: message)
                    }
                }
                
                if values[Types.method] as! String == MethodName.ImageFromAgent {
                    let imageArr = values[Types.array] as? [Any]
                    let imageUrl = self.baseURL + (imageArr?[2] as! String)
                    self.delegate?.receiveImage(imagePath: imageUrl)
                }
                
                if values[Types.method] as! String == MethodName.completedAlert {
                    let array = values[Types.array] as? [Any]
                    if array?[1] as? Int == self.userId && array?[2] as? Int == self.sessionId{
                        print("The chat has been closed by the Admin")
                        UserDefaults.standard.removeObject(forKey: "visitorId")
                        UserDefaults.standard.removeObject(forKey: "sessionId")
                        print(self.userId, self.sessionId)
                    }
                }
            }
        }
    }
    
     func audioUpload(path: URL, fileName: String) {
        let uploadPath = "https://tlp.360scrm.com/api/WebChat/UploadFiles?sessionId=\(self.sessionId)&visitorId=\(self.userId)"
        DocumentUpload.audioUpload(path: path, url: uploadPath, fileName: fileName)
    }
    
    public func imageUpload(image: UIImage) {
        let uploadPath = "https://tlp.360scrm.com/api/WebChat/UploadFiles?sessionId=\(self.sessionId)&visitorId=\(self.userId)"
        DocumentUpload.ImageUpload(image, url: uploadPath)
    }
}
