 //
//  PostsController.swift
//  App
//
//  Created by Sihoon Oh on 2018. 5. 22..
//

import Vapor

struct PostsController: RouteCollection {
    func boot(router: Router) throws {
        let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
        let postsRoute = authSessionRoutes.grouped("api", "posts")
        postsRoute.get(use: getAllHandler)
        postsRoute.get(Post.parameter, use: getHandler)
        postsRoute.get(Post.parameter, "categories", use: getCategoriesHandler)
        postsRoute.post(Post.parameter, "categories", Category.parameter, use: addCategoriesHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = postsRoute.grouped(tokenAuthMiddleware)
        tokenAuthGroup.post(use: createHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Post]> {
        return Post.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Post> {
        return try req.parameters.next(Post.self)
    }
    
    func createHandler(_ req: Request) throws -> Future<Post> {
        return try req.content.decode(PostCreateData.self).flatMap(to: Post.self) {
            postData in
            let user = try req.requireAuthenticated(User.self)
            let post = Post(title: postData.title,
                            subTitle: postData.subTitle!,
                            body: postData.body,
                            creatorID: try user.requireID())
            return post.save(on: req)
        }
    }
    
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Post.self).flatMap(to: [Category].self) { post in
            return try post.categories.query(on: req).all()
        }
    }
    
    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self,
                           req.parameters.next(Post.self),
                           req.parameters.next(Category.self)) { post, category in
            let pivot = try PostCategoryPivot(post.requireID(), category.requireID())
            return pivot.save(on: req).transform(to: .ok)
        }
    }
 }
 
extension Post: Parameter {}
 
 struct PostCreateData: Content {
    
    var id: UUID?
    var title: String
    var subTitle: String?
    var body: String?
    var creatorID: User.ID
    var categoryID: Category.ID
    var createdAt: Date?
    var updatedAt: Date?
 }
