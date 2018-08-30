//
//  UsersController.swift
//  App
//
//  Created by Sihoon Oh on 2018. 5. 22..
//

import Vapor
import Authentication
import Crypto

struct UsersController: RouteCollection {
  func boot(router: Router) throws {
    let usersRoute = router.grouped("api", "users")
    usersRoute.post(use: createHandler)
    usersRoute.get(User.Public.parameter, use: getHandler)
    
    let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
    let basicAuthGroup = usersRoute.grouped(basicAuthMiddleware)
    basicAuthGroup.post("login", use: loginHandler)
  }
  
  func createHandler(_ req: Request) throws -> Future<User> {
    return try req.content.decode(User.self).flatMap(to: User.self) { user in
      user.password = try BCrypt.hash(user.password)
      return user.save(on: req)
    }
  }
  
  func getHandler(_ req: Request) throws -> Future<User.Public> {
    return try req.parameters.next(User.Public.self)
  }
  
  func loginHandler(_ req: Request) throws -> Future<Token> {
    let user = try req.requireAuthenticated(User.self)
    let token = try Token.generate(for: user)
    return token.save(on: req)
  }
}

extension User: Parameter {}
extension User.Public: Parameter {}
