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
    let name, email: String
    let visitorSession: VisitorSession

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
        case email = "Email"
        case visitorSession = "VisitorSession"
    }
}
// MARK: - VisitorSession
struct VisitorSession: Codable {
    let id: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case name = "Name"
    }
}
