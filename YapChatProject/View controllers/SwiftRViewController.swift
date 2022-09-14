//
//  SwiftRViewController.swift
//  YapChatProject
//
//  Created by Ahmad on 02/09/2022.
//

import UIKit
import SignalRSwift
import SDWebImage
import AVFoundation
import MobileCoreServices
import UniformTypeIdentifiers

class SwiftRViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
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
    var soundRecorder : AVAudioRecorder!
    var soundPlayer: AVAudioPlayer!
    
    let userId = UserDefaults.standard.integer(forKey: "visitorId")
    let sessionId = UserDefaults.standard.integer(forKey: "sessionId")
    var imageUrl: String = ""
    let fileName = "abc.wav"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        26599
//        16406
        messageTxtField.delegate = self
        
        hubConnection = HubConnection(withUrl: "https://tlp.360scrm.com/")
        
        chat = self.hubConnection.createHubProxy(hubName: "notificationHub")
        
        openHubConnection()
        
//        if userId != 0 && sessionId != 0 {
//            self.detailsOfVisitorChat(visitorId: self.userId, sessionId: self.sessionId)
//        } else {
            self.saveVisitor(name: "iosAhmed", email: "iostesting@gmail.com", phoneNumber: "0334")
//        }
        
        receiveMessage()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.yourFuncHere()
        }
        print("\(userId), \(sessionId)")
        
        setupRecorder()
        playBtn.isEnabled = false
        
        recordBtn.addTarget(self, action: #selector(recordAct), for: .touchUpInside)
        playBtn.addTarget(self, action: #selector(playerAct), for: .touchUpInside)
        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(sendImage), for: .touchUpInside)
    }
    
    func yourFuncHere() {
        print("name \(self.detailOfVisitor?.webChatDetialVisitor?[0].name)")
        if let text = self.chatTextView.text {
            self.chatTextView.text = "\(text)\n\n\(self.detailOfVisitor?.webChatDetialVisitor?[0].name): \(self.detailOfVisitor?.webChatDetialVisitor?[0].message)"}
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
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupRecorder() {
        let audioFilename = getDocumentDirectory().appendingPathComponent(fileName)
        let recordingSettings = [
            AVFormatIDKey : Int(kAudioFormatLinearPCM),
            AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey : 2,
            AVSampleRateKey : 44100.2
        ] as [String : Any]
        
        do {
            soundRecorder = try AVAudioRecorder(url: audioFilename, settings: recordingSettings)
            soundRecorder.delegate = self
        }
        catch {
            print(error)
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord)
        } catch {
            assertionFailure("Failed to configure `AVAAudioSession`: \(error.localizedDescription)")
        }
    }
    
    func setupPlayer() {
        let audioFileName = getDocumentDirectory().appendingPathComponent(fileName)
        print("Audio file name \(audioFileName)")
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileName)
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        }
        catch {
            print(error)
        }
    }
    
    @objc func recordAct() {
        if recordBtn.titleLabel?.text == "Record" {
            soundRecorder.record()
            recordBtn.setTitle("Stop", for: .normal)
            playBtn.isEnabled = false
        }
        else {
            soundRecorder.stop()
            recordBtn.setTitle("Record", for: .normal)
            playBtn.isEnabled = false
            
        }
    }
    
    @objc func playerAct() {
        if playBtn.titleLabel?.text == "Play" {
            playBtn.setTitle("Stop", for: .normal)
            recordBtn.isEnabled = false
            setupPlayer()
            soundPlayer.play()
        }
        else {
            soundRecorder.stop()
            playBtn.setTitle("Play", for: .normal)
            recordBtn.isEnabled = false
            
        }
    }
    
    
    @objc func sendMessage() {
        
        self.message = messageTxtField.text!
        self.saveVisitorChat(visitorSessionID: self.user?.visitorSession.id ?? 0, visitorId: self.user?.id ?? 1, message: message)
        self.detailsOfVisitorChat(visitorId: self.user?.id ?? 0, sessionId: self.user?.visitorSession.id ?? 1)
        
        if let text = self.chatTextView.text {
            self.chatTextView.text = "\(text)\n\n\(self.user?.name): \(self.message)"}
    }
    
    @objc func sendImage() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func receiveMessage() {
        hubConnection.received = { data in
            
            if let values = data as? [String: Any] {
                print("Method Name is: \(values[Types.method]!), Hubname: \(values[Types.hubName]!), messageReceived: \(values[Types.array]!)")
                
                if values[Types.method] as! String == MethodName.broadcastMessage {
                    
                    let array = values[Types.array] as? [Any]
                    if array?[1] as? Int == self.userId {
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
                    let imageUrl = self.baseURL + (imageArr?[2] as! String)
                    print("imageUrl \(imageUrl)")
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
                print("visitor Typing invoking")
            }
        }
    }
    
    func agentTyping(label: UILabel, text: String) {
        label.text = text
    }
    
    func uploadImage() {
        
    }
   
}

extension SwiftRViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.visitorTyping()
        return true
    }
}

extension SwiftRViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let imageLink = "https://tlp.360scrm.com/api/WebChat/UploadFiles?sessionId=\(user?.visitorSession.id ?? 0)&visitorId=\(user!.id)"
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            print("Image data \(image)")
            Image.ImageUpload(image, url: imageLink)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SwiftRViewController: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playBtn.isEnabled = true
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordBtn.isEnabled = true
        playBtn.setTitle("Play", for: .normal)
    }
}

extension SwiftRViewController: UIDocumentPickerDelegate {
    
    func selectFiles() {
        let types = UTType.types(tag: "json",
                                 tagClass: UTTagClass.filenameExtension,
                                 conformingTo: nil)
        let documentPickerController = UIDocumentPickerViewController(
                forOpeningContentTypes: types)
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
    }
          

    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }


    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
}
