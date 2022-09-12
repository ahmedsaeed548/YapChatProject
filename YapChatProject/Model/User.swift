//
//  User.swift
//  YapChatProject
//
//  Created by Ahmad on 31/08/2022.
//

import Foundation

struct User: Codable {
    let model: Model

    enum CodingKeys: String, CodingKey {
        case model = "Model"
    }
}

// MARK: - Model
struct Model: Codable {
    let id: Int
    let connectionID: Int?
    let name, email: String
    let registerDate, createdOn, modifiedOn: String?
    let visitorSession: VisitorSession
    let chatDetail: String?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case connectionID = "ConnectionId"
        case name = "Name"
        case email = "Email"
        case registerDate = "RegisterDate"
        case createdOn = "CreatedOn"
        case modifiedOn = "ModifiedOn"
        case visitorSession = "VisitorSession"
        case chatDetail = "ChatDetail"
    }
}
// MARK: - VisitorSession
struct VisitorSession: Codable {
    let id: Int?
    let name: String?
    let createdOn, connectedWithID, wcVisitorID, agentName: [String]?

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case createdOn = "CreatedOn"
        case connectedWithID = "ConnectedWithId"
        case wcVisitorID = "WcVisitorId"
        case agentName = "AgentName"
    }
}

