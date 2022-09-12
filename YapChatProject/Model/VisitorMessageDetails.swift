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
    let displayName: String?
    let conversationDetailID: Int?
    let connectionID: String?
    let email: String?
    let sessionID: Int?
    let conversationReplyID, visitorConnectionID, chatMessage: String?
    let message, messageDate: String?
    let isMediaFile: String?
    let isReply: Bool
    let url, webChatDetialVisitorExtension, tags: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case wcVisitorID = "WcVisitorId"
        case name = "Name"
        case displayName = "DisplayName"
        case conversationDetailID = "ConversationDetailId"
        case connectionID = "ConnectionId"
        case email = "Email"
        case sessionID = "SessionId"
        case conversationReplyID = "ConversationReplyId"
        case visitorConnectionID = "VisitorConnectionId"
        case chatMessage = "ChatMessage"
        case message = "Message"
        case messageDate = "MessageDate"
        case isMediaFile = "IsMediaFile"
        case isReply = "IsReply"
        case url = "Url"
        case webChatDetialVisitorExtension = "Extension"
        case tags = "Tags"
    }
}
