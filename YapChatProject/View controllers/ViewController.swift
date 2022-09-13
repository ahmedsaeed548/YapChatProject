//
//  ViewController.swift
//  YapChatProject
//
//  Created by Ahmad on 31/08/2022.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var phoneNumTextField: UITextField!
    var nameTxt: String = ""
    var emailTxt: String = ""
    var phoneNumber: String = ""
    var user : Model?

    
    @IBOutlet weak var saveBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBtn.addTarget(self, action: #selector(isTapped), for: .touchUpInside)
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

                    self.navigateToSendMessage()
                    self.user = response.model
                case .failure(let failure):
                    print(failure)
            }
        }
       
    }
        
        func navigateToSendMessage() {
            DispatchQueue.main.async { [weak self] in
                let vc = self?.storyboard?.instantiateViewController(withIdentifier: "SendMessageViewController") as! SendMessageViewController
                vc.user = self?.user
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        @objc func isTapped() {
            
            self.nameTxt = "ios"
            self.emailTxt = "iostest@gmail.com"
            self.phoneNumber = "03091784743"
            
            self.saveVisitor(name: self.nameTxt, email: self.emailTxt, phoneNumber: self.phoneNumber)
        }
    }
    
