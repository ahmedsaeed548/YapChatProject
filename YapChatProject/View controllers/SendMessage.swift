////
////  SendMessageViewController.swift
////  YapChatProject
////
////  Created by Ahmad on 31/08/2022.
////
//
//import UIKit
//import SignalRSwift
//import CoreData
//
//
//class SendMessageViewController: UIViewController, UITextFieldDelegate {
//
//    @IBOutlet weak var sendBtn: UIButton!
//    @IBOutlet weak var messageTxtField: UITextField!
//
//    @IBOutlet weak var receiveBtn: UIButton!
//    @IBOutlet weak var typingLbl: UILabel!
////    var hubConnection: HubConnection!
////    var chat: HubProxy!
////    var user: Model?
////    var userMessage: UserMessage?
////    var detailOfVisitor: VisitorMessageDetails?
////    var visitorDetails: [WebChatDetialVisitor]?
////    var message: [String] = []
////    var id: Int?
////    var name: String?
////    var messages: String?
////    var messageTxt: String = ""
//    var chat = Chat()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        messageTxtField.delegate = self
//        view.backgroundColor = .yellow
////        hubConnection = HubConnection(withUrl: "https://tlp.360scrm.com/")
////        chat = self.hubConnection.createHubProxy(hubName: "notificationHub")
////
////        openHubConnection()
////
////
////        hubConnection.received = { data in
////            print(data)
////        }
//
//        chat.createConnection()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            self.chat.openConnection()
//        }
//
//        chat.receiveMessage()
//        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
//
//        receiveBtn.addTarget(self, action: #selector(receiveMessage), for: .touchUpInside)
//    }
//
////    func openHubConnection() {
////
////        hubConnection.started = {
////            self.typingLbl.text = "Connected"
////        }
////
////        hubConnection.reconnecting = {
////            self.typingLbl.text = "Reconnecting"
////            print("Reconnecting...")
////        }
////
////        hubConnection.reconnected = {
////            self.typingLbl.text = "Reconnected, connection ID: \(self.hubConnection.connectionId ?? " ")"
////            print("Reconnected.")
////        }
////
////        hubConnection.closed = {
////            self.typingLbl.text = "Hub Disconnected"
////            print("Hub Disconnected")
////        }
////
////        hubConnection.connectionSlow = {
////            self.typingLbl.text = "Connection Slow"
////            print("Connection slow...") }
////
////        hubConnection.error = { error in
////            print(error)
////        }
////
////        hubConnection.start()
////    }
////
////    func saveVisitorChat(visitorSessionID: Int, visitorId: Int, message: String) {
////        let parameters: [String : Any ] = [
////            "WcVisitorSessionId": visitorSessionID,
////            "wcVisitorId": visitorId,
////            "message": message,
////        ]
////        ServiceManager.postApiCall(parameters: parameters, apiKey: ApiKey.saveVisitorChat) {(result : Result<UserMessage,Error>) in
////            switch result {
////            case .success(let response):
////                print(response)
////                self.userMessage = response
////            case .failure(let failure):
////                print(failure)
////            }
////        }
////    }
////
////    func detailsOfVisitorChat(visitorId: Int, sessionId: Int) {
////
////        let parameters: [String : Any ] = [
////            "VisitorId": visitorId,
////            "SessionId": sessionId,
////        ]
////        ServiceManager.postApiCall(parameters: parameters, apiKey: ApiKey.getDetailsOfVisitorChatSession) {(result : Result<VisitorMessageDetails,Error>) in
////            switch result {
////            case .success(let response):
////                print(response)
////                self.detailOfVisitor = response
////            case .failure(let failure):
////                print(failure)
////            }
////        }
////    }
//
//    @objc func sendMessage() {
//        let message = messageTxtField.text!
//        chat.sendMessage(message: message)
//    }
////    func visitorTyping() {
////        chat.invoke(method: "visitorTyping", withArgs: [self.user?.id ?? 0,  self.user?.name ?? "Ahmed"]) { response, error  in
////            if let error = error {
////                print(error)
////            } else {
////                print("\(self.user!.name) is typing..")
////            }
////        }
////    }
//}
//
//extension SendMessageViewController {
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        chat.visitorTyping()
//        return true
//    }
//}
