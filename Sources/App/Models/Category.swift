//
//  Category.swift
//  App
//
//  Created by Sihoon Oh on 2018. 5. 27..
//

import Vapor
import FluentPostgreSQL

final class Category: Codable {
    var id: Int?
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

extension Category: PostgreSQLModel {}
extension Category: Migration {}
extension Category: Content {}

extension Category {
    var posts: Siblings<Category, Post, PostCategoryPivot> {
        return siblings()
    }
}
