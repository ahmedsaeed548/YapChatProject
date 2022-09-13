//
//  Chat.swift
//  YapChatProject
//
//  Created by Ahmad on 13/09/2022.
//

import Foundation
import UIKit
import SignalRSwift

public class Chat: NSObject {
    
    private var hubConnection : HubConnection!
    private var chatHub : HubProxy!
    private var user : Model?
    private var userMessage : UserMessage?
    private var detailOfVisitor : VisitorMessageDetails?
    private var baseURL = "https://tlp.360scrm.com"
    
    @IBOutlet weak var typingLBl: UILabel!
    
    public func createConnection() {
        
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
    }
    
    public func closeConnection(reason: String) {
        hubConnection.closed = { print("\(reason)") }
    }
    
    public func openConnection(name: String, email: String, phoneNumber: String) {
            
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
                case .failure(let failure):
                    print(failure)
                }
            }
    }
    
    public func sendMessage(message: String) {
        
        let parameters: [String : Any ] = [
            "WcVisitorSessionId": self.user?.visitorSession.id ?? 0,
            "wcVisitorId": self.user?.id ?? 1,
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
    
    public func visitorTyping() {
        chatHub.invoke(method: "visitorTyping", withArgs: [self.user?.id ?? 0,  self.user?.name ?? "Ahmed"]) { response, error  in
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
    
   public func receiveMessage() {
        hubConnection.received = { data in
            
            if let values = data as? [String: Any] {
                print("Method Name is: \(values[Types.method]!), Hubname: \(values[Types.hubName]!), messageReceived: \(values[Types.array]!)")
                
                if values[Types.method] as! String == MethodName.broadcastMessage {
                    
                    let array = values[Types.array] as? [Any]
                    if array?[1] as? Int == self.user?.id {
                        print("Message received \(array![2])")
                    }
                }
                
                if values[Types.method] as! String == MethodName.agentTypingAlert {
                    self.agentTyping(label: self.typingLBl, text: "Agent is typing..")
                } else {
                    self.agentTyping(label: self.typingLBl, text: " ")
                    print(".")
                }
                
                if values[Types.method] as! String == MethodName.ImageFromAgent {
                    let imageArr = values[Types.array] as? [Any]
                    let imageUrl = self.baseURL + (imageArr?[2] as! String)
                    print("imageUrl \(imageUrl)")
                }
            }
        }
    }
}
