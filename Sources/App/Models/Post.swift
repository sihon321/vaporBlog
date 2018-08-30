//
//  Post.swift
//  App
//
//  Created by Sihoon Oh on 2018. 5. 22..
//

import Foundation
import FluentPostgreSQL
import Vapor

final class Post: Codable {
    
    var id: Int?
    var title: String
    var subTitle: String?
    var body: String?
    var creatorID: User.ID
    var createdAt: Date?
    var updatedAt: Date?
    
    init(title: String, subTitle: String, body: String?, creatorID: User.ID) {
        self.title = title
        self.subTitle = subTitle
        self.body = body
        self.creatorID = creatorID
    }
}

extension Post {
    static var createdAtKey: TimestampKey? = \.createdAt
    static var updatedAtKey: TimestampKey? = \.updatedAt
}

extension Post: PostgreSQLModel {}
extension Post: Content {}
extension Post: Migration {}

extension Post {
    var user: Parent<Post, User> {
        return parent(\.creatorID)
    }
    
    var categories: Siblings<Post, Category, PostCategoryPivot> {
        return siblings()
    }
}
