//
//  VisitorMessageDetails.swift
//  signalRConnection
//
//  Created by Ahmad on 30/08/2022.
//

import Foundation

struct VisitorMessageDetails: Codable {
    let visitorID, visitorSession: Int
    let visitorSessionName: String
    let webChatDetialVisitor: [WebChatDetialVisitor]?

    enum CodingKeys: String, CodingKey {
        case visitorID = "VisitorId"
        case visitorSession = "VisitorSession"
        case visitorSessionName = "VisitorSessionName"
        case webChatDetialVisitor = "WebChatDetialVisitor"
    }
}


// MARK: - WebChatDetialVisitor
struct WebChatDetialVisitor: Codable {
    let id: Int?
    let wcVisitorID: Int?
    let name: String?
    let connectionID: String?
    let sessionID: Int?
    let message, messageDate: String?
    let isMediaFile: Bool?
    let isReply: Bool?
    let webChatDetialVisitorExtension: String?
     //  let tags: NSNull
    //    let displayName: String?
    //    let conversationDetailID: Int?
    //    let email: String?
    //    let conversationReplyID, visitorConnectionID, chatMessage: String?
       let url: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case wcVisitorID = "WcVisitorId"
        case name = "Name"
        case connectionID = "ConnectionId"
        case sessionID = "SessionId"
        case message = "Message"
        case messageDate = "MessageDate"
        case isMediaFile = "IsMediaFile"
        case isReply = "IsReply"
        case url = "Url"
        case webChatDetialVisitorExtension = "Extension"
//        case tags = "Tags"
        //        case conversationReplyID = "ConversationReplyId"
        //        case visitorConnectionID = "VisitorConnectionId"
        //        case chatMessage = "ChatMessage"
        //  case email = "Email"
        //        case displayName = "DisplayName"
        //        case conversationDetailID = "ConversationDetailId"
    }
}
