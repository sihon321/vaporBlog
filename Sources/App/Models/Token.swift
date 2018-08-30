//
//  Token.swift
//  App
//
//  Created by Sihoon Oh on 2018. 8. 12..
//

import Foundation
import Vapor
import FluentPostgreSQL

final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension Token: PostgreSQLUUIDModel {}
extension Token: Content {}
extension Token: Migration {}

import Crypto

extension Token {
    var user: Parent<Token, User> {
        return parent(\.userID)
    }
}

import Random

extension Token {
    static func generate(for user: User) throws -> Token {
        let random = OSRandom().generateData(count: 16)
        return try Token(token: random.base64EncodedString(), userID: user.requireID())
    }
}

import Authentication

extension Token: Authentication.Token {
    static let userIDKey: UserIDKey = \Token.userID
    typealias UserType = User
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}
