//
//  DetailOfChatVisitorViewController.swift
//  YapChatProject
//
//  Created by Ahmad on 31/08/2022.
//

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var sendMsgBtn: UIButton!
    @IBOutlet weak var messageTxtField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    var chat = Chat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTxtField.delegate = self
        chat.createConnection()
        chat.openConnection(name: "ahmedtest", email: "ah@gmail.com", phoneNumber: "0324234234")
        sendMsgBtn.addTarget(self, action: #selector(saveVisitor), for: .touchUpInside)
        saveBtn.addTarget(self, action: #selector(disconnectConnection), for: .touchUpInside)
    }
    
    @objc func saveVisitor() {
        if let message = messageTxtField.text {
            chat.sendMessage(message: message)
        }
    }
    
    @objc func disconnectConnection() {
        chat.closeConnection(reason: "Disconnected!")
    }
}

extension ChatViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        chat.visitorTyping()
        return true
    }
}
