//
//  Enums.swift
//  YapChatProject
//
//  Created by Ahmad on 31/08/2022.
//

import Foundation


enum ApiKey {
    static let saveVisitor = "/api/WebChat/SaveVisitor"
    static let saveVisitorChat = "/api/WebChat/SaveVisitorChat"
    static let getDetailsOfVisitorChatSession = "/api/WebChat/GetDetailOfVisitorChatSessionWise"
    static let uploadFiles = "/api/WebChat/UploadFiles"
    
}

enum MethodName {
    static let visitorTypingAlert = "visitorTypingAlert"
    static let agentTypingAlert = "agentTypingAlert"
    static let alert = "alert"
    static let broadcastMessage = "broadcastMessage"
    static let ImageFromAgent = "ImageFromAgent"
}

enum Types {
    static let method = "M"
    static let array = "A"
    static let hubName = "H"
}
