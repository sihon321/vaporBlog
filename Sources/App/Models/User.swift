//
//  User.swift
//  App
//
//  Created by Sihoon Oh on 2018. 5. 19..
//

import Foundation
import FluentPostgreSQL
import Vapor

final class User: Codable {
    var id: UUID?
    var userID: String
    var password: String
    var name: String
    
    init(userID: String, password: String, name: String) {
        self.userID = userID
        self.password = password
        self.name = name
    }
    
    final class Public: Codable {
        var id: UUID?
        var userID: String
        var name: String
        
        init(userID: String, name: String) {
            self.userID = userID
            self.name = name
        }
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Migration {}
extension User: Content {}

extension User.Public: PostgreSQLUUIDModel {
    static let entity = User.entity
}
extension User.Public: Content {}

extension User {
    var post: Children<User, Post> {
        return children(\.creatorID)
    }
}

import Authentication

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.userID
    static var passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User: PasswordAuthenticatable { }
extension User: SessionAuthenticatable { }
