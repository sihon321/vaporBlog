//
//  PostCategoryPivot.swift
//  App
//
//  Created by Sihoon Oh on 2018. 8. 26..
//

import FluentPostgreSQL
import Vapor
import Foundation

final class PostCategoryPivot: PostgreSQLUUIDPivot {
    var id: UUID?
    var postID: Post.ID
    var categoryID: Category.ID
    
    typealias Left = Post
    typealias Right = Category
    static let leftIDKey: LeftIDKey = \PostCategoryPivot.postID
    static let rightIDKey: RightIDKey = \PostCategoryPivot.categoryID
    
    init(_ postID: Post.ID, _ categoryID: Category.ID) {
        self.postID = postID
        self.categoryID = categoryID
    }
}

extension PostCategoryPivot: Migration {}
