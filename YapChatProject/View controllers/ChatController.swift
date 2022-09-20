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
    var image = UIImage(named: "image")
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTxtField.delegate = self
        
        chat.createConnection()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            self.chat.openConnection()
        }
        
        chat.receiveMessage()
        
        sendMsgBtn.addTarget(self, action: #selector(saveVisitor), for: .touchUpInside)
        saveBtn.addTarget(self, action: #selector(sendImage), for: .touchUpInside)
    }
    
    @objc func saveVisitor() {
        if let message = messageTxtField.text {
            chat.sendMessage(message: message)
        }
    }
    
    @objc func sendImage() {
        chat.imageUpload(image: image!)
    }
}

extension ChatViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        chat.visitorTyping()
        return true
    }
}
