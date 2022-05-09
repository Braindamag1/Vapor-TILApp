//
//  File.swift
//
//
//  Created by YJ.Lee on 2022/5/9.
//

import Vapor

struct CategoriesController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let categories = routes.grouped("api", "categories")
        categories.post(use: createHandler)
        categories.get(use: getAllHandler)
        categories.get(":categoryID", use: getHandler)
        categories.get(":categoryID","acronyms", use: getAcronymsHandler)
    }

    // C- create POST
    func createHandler(_ req: Request) throws
        -> EventLoopFuture<Category> {
        let category = try req.content.decode(Category.self)
        return category.save(on: req.db)
            .map { _ in
                return category
            }
    }

    // R- retrieve GET
    func getAllHandler(_ req: Request)
        -> EventLoopFuture<[Category]> {
        Category.query(on: req.db)
            .all()
    }
    
    func getHandler(_ req: Request)
        -> EventLoopFuture<Category> {
        Category.find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    
    func getAcronymsHandler(_ req: Request)
    ->EventLoopFuture<[Acronym]> {
        return Category.find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { category in
                return category.$acronyms.get(on: req.db)
            }
    }
}
