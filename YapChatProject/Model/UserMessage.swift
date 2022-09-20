//
//  UserMessage.swift
//  YapChatProject
//
//  Created by Ahmad on 31/08/2022.
//

import Foundation

struct UserMessage: Codable {
    let id: Int?
    let wcVisitorID: Int?
  //  let fromID: Int?
    let wcVisitorSessionID: Int?
    let fromName: String?
    let toID: Int?
    let toName: String?
    let message: String?
    let messageDate: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case wcVisitorID = "WcVisitorId"
      //  case fromID = "FromId"
        case wcVisitorSessionID = "WcVisitorSessionId"
        case fromName = "FromName"
        case toID = "ToId"
        case toName = "ToName"
        case message = "Message"
        case messageDate = "MessageDate"
    }
}
