//
//  SwiftRExample.swift
//  YapChatProject
//
//  Created by Ahmad on 07/09/2022.
//

import Foundation

import Foundation
import SwiftR

class DemoViewController: UIViewController {
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var chatTextView: UITextView!
    var chatHub: Hub!
    var connection: SignalR!
    var name: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        connection = SignalR("http://swiftr.azurewebsites.net")
        connection.useWKWebView = true
        connection.signalRVersion = .v2_2_2
        
        connection.transport = .auto // This is the default
        connection.transport = .webSockets
        connection.transport = .serverSentEvents
        connection.transport = .foreverFrame
        connection.transport = .longPolling
        
        chatHub = Hub("chatHub")
        chatHub.on("broadcastMessage") { [weak self] args in
            if let name = args?[0] as? String, let message = args?[1] as? String, let text = self?.chatTextView.text {
                self?.chatTextView.text = "\(text)\n\n\(name): \(message)"
            }
        }
        connection.addHub(chatHub)
        
         // SignalR events
        
        connection.starting = { [weak self] in
            print("Starting..")
        }

        connection.reconnecting = { [weak self] in
        print("reconencting")
        }

        connection.connected = { [weak self] in
            print("Connection ID: \(self!.connection.connectionID!)")
        }

        connection.reconnected = { [weak self] in
         print("Reconnected. Connection ID: \(self!.connection.connectionID!)")
        }

        connection.disconnected = { [weak self] in
        
            print("disconnected")
        }

        connection.connectionSlow = { print("Connection slow...") }

        connection.error = { [weak self] error in
            print("Error: \(error)")
            
            if let source = error?["source"] as? String, source == "TimeoutException" {
                print("Connection timed out. Restarting...")
                self?.connection.start()
            }
        }
        
        connection.start()
    }
    
    @objc func sendMessage() {
        self.name = "Rival"
        if let hub = chatHub {
            let message = messageTextField.text
            do {
                try hub.invoke("send", arguments: [name, message])
            }
            catch {
                print(error)
            }
        }
        messageTextField.resignFirstResponder()
    }
}

