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

class SwiftRViewController: UIViewController, UITextFieldDelegate, ChatDelegate {


    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var typingLBl: UILabel!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var messageTxtField: UITextField!
    @IBOutlet weak var typingLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var documentBtn: UIButton!
    
    var soundRecorder : AVAudioRecorder!
    var soundPlayer: AVAudioPlayer!
    var chat = Chat()
    var text = ""
    let fileName = UUID().uuidString + ".wav"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageTxtField.delegate = self
        
        chat.createConnection(key: "123")
        
        chat.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.chat.openConnection(name: "ios008", email: "ios008@gmail.com", phoneNumber: "03344978228")
        }
        chat.printUserDefaultValues()
        
        chat.receiveData()
        setupRecorder()
        
        playBtn.isEnabled = false
        
        recordBtn.addTarget(self, action: #selector(recordAct), for: .touchUpInside)
        playBtn.addTarget(self, action: #selector(playerAct), for: .touchUpInside)
        sendBtn.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(sendImage), for: .touchUpInside)
     
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func setupRecorder() {
        let audioFilename = getDocumentDirectory().appendingPathComponent(fileName)
        print("Audio file Recorder name: \(audioFilename)")
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
        let audioFilePath = getDocumentDirectory().appendingPathComponent(fileName)
        print("Audio file Player name: \(audioFilePath)")
        chat.audioUpload(path: audioFilePath, fileName: fileName)
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFilePath)
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
        
        let message = messageTxtField.text!
        chat.sendMessage(message: message)
        if let text = self.chatTextView.text {
            self.chatTextView.text = "\(text)\n\n\(chat.userMessage?.fromName): \(message)"}
    }
    
    @objc func sendImage() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func receiveMessage(message: String) {
        if let text = self.chatTextView.text {
            self.chatTextView.text = "\(text)\n\n\(message)"
        }
        print("Message \(message)")
    }
    
    func receiveImage(imagePath: String) {
        print("received Image: \(imagePath)")
    }
    
    func fetchPreviousMessages(messages: [WebChatDetialVisitor]) {
        
        for message in messages {
            if message.isReply == true {
                print("Admin Message \(message.message ?? "")")
            } else {
                print("User Message: \(message.message ?? "")")
            }
        }
    }
    
    
//   @objc func openDocument() {
//        let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
//                importMenu.delegate = self
//                importMenu.modalPresentationStyle = .formSheet
//                 self.present(importMenu, animated: true, completion: nil)
//    }
   
}

extension SwiftRViewController {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        chat.visitorTyping()
        return true
    }
}

extension SwiftRViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            print("Image data \(image)")
            chat.imageUpload(image: image)
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
//
//extension SwiftRViewController : UIDocumentPickerDelegate {
//
//    func documentMenu(_ documentMenu: UIDocumentPickerViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
//        documentPicker.delegate = self
//        self.present(documentPicker, animated: true, completion: nil)
//    }
//
//    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
//        print("url = \(url)")
//    }
//
//    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
//        dismiss(animated: true, completion: nil)
//    }
//}


