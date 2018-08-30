//
//  CategoriesController.swift
//  App
//
//  Created by Sihoon Oh on 2018. 5. 27..
//

import Vapor

struct CategoriesController: RouteCollection {
    func boot(router: Router) throws {
        let categoriesRoute = router.grouped("api", "categories")
        categoriesRoute.post(use: createHandler)
        categoriesRoute.get(use: getAllHandler)
    }
    
    func createHandler(_ req: Request) throws -> Future<Category> {
        return try req.content.decode(Category.self).flatMap(to: Category.self) { category in
            return category.save(on: req)
        }
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    func getHandler(_ req: Request) throws -> Future<Category> {
        return try req.parameters.next(Category.self)
    }
}

extension Category: Parameter {}
