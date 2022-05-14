//
//  File.swift
//
//
//  Created by YJ.Lee on 2022/5/8.
//

import Fluent
import Vapor

struct AcronymsController: RouteCollection {
    // register routes
    func boot(routes: RoutesBuilder) throws {
        let acronymsRoutes = routes.grouped("api", "acronyms")
        // acronymsRoutes.post(use: createHandler)
        //acronymsRoutes.post(":acronymID", "categories", ":categoryID", use: addCategoryHandler)
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.get(":acronymID", use: getHandler)
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
        acronymsRoutes.get(":acronymID", "categories", use: getCategories)
        //acronymsRoutes.put(":acronymID", use: updateHandler)
        //acronymsRoutes.delete(":acronymID", use: deleteHandler)
        //acronymsRoutes.delete(":acronymID", "categories", ":categoryID", use: deleteCategoryHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("sorted", use: sortHandler)

        let tokenAuthMiddleware = Token.authenticator()
        let guardAuthMiddleware = User.guardMiddleware()
        let tokenAuthGroup = acronymsRoutes.grouped(tokenAuthMiddleware,
                                                    guardAuthMiddleware)
        tokenAuthGroup.post( use: createHandler)
        tokenAuthGroup.delete(":acronymID", use: deleteHandler)
        tokenAuthGroup.put("acronymID", use: updateHandler)
        tokenAuthGroup.post(":acronymID","categories",":categoryID", use: addCategoryHandler)
        tokenAuthGroup.delete(":acronymID","categories",":categoryID", use: deleteCategoryHandler)
    }

    // C- create - POST
    func createHandler(_ req: Request) throws
        -> EventLoopFuture<Acronym> {
        let dto = try req.content.decode(CreateAcronymData.self)
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        let acronym = Acronym(short: dto.short, long: dto.long, userID: userID )
        return acronym.save(on: req.db)
            .map { _ in
                acronym
            }
    }

    // CreateRelationship should return EventLoopFuture<HTTPStatus>
    func addCategoryHandler(_ req: Request)
        -> EventLoopFuture<HTTPStatus> {
        let categoryQuery = Category.find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let acronymQuery = Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))

        return acronymQuery
            .and(categoryQuery)
            .flatMap { acronym, category in
                acronym
                    .$categories
                    .attach(category, on: req.db)
                    .transform(to: .created)
            }
    }

    // R- retrieve -GET
    func getAllHandler(_ req: Request)
        -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db)
            .all()
    }

    func getHandler(_ req: Request)
        -> EventLoopFuture<Acronym> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    func getUserHandler(_ req: Request)
        -> EventLoopFuture<User.Public> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user
                    .get(on: req.db)
                    .convertToPublic()
            }
    }

    func getCategories(_ req: Request)
        -> EventLoopFuture<[Category]> {
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$categories
                    .query(on: req.db)
                    .all()
            }
    }

    // U- update - PUT
    func updateHandler(_ req: Request) throws
        -> EventLoopFuture<Acronym> {
        let updateDTO = try req.content.decode(CreateAcronymData.self)
        let user = try req.auth.require(User.self)
        let userID = try user.requireID()
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updateDTO.short
                acronym.long = updateDTO.long
                acronym.$user.id = userID
                return acronym.save(on: req.db)
                    .map { _ in
                        acronym
                    }
            }
    }

    // D- delete -DELETE
    func deleteHandler(_ req: Request)
        -> EventLoopFuture<HTTPStatus> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }

    // A02A1D4F-9C32-4224-A39B-0B3EB400BFD
    // E9F89E62-1A5D-43D3-9E88-2ED9DC25937D
    // Delete Relationship should return EventLoopFuture<HTTPStatus>--Just pivot not acronym or category
    func deleteCategoryHandler(_ req: Request)
        -> EventLoopFuture<HTTPStatus> {
        let categoryQuery = Category.find(req.parameters.get("categoryID"), on: req.db)
            .unwrap(or: Abort(.notFound))
        let acronymQuery = Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))

        return acronymQuery.and(categoryQuery)
            .flatMap { acronym, category in
                acronym
                    .$categories
                    .detach(category, on: req.db) // detach a single model by deleting a pivot
                    .transform(to: .noContent)
            }
    }

    // search
    func searchHandler(_ req: Request) throws
        -> EventLoopFuture<[Acronym]> {
        guard let searchItem = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req.db)
            .group(.or) { or in
                or.filter(\.$short == searchItem)
                or.filter(\.$long == searchItem)
            }
            .all()
    }

    // first
    func getFirstHandler(_ req: Request)
        -> EventLoopFuture<Acronym> {
        Acronym.query(on: req.db)
            .first()
            .unwrap(or: Abort(.notFound))
    }

    // sort
    func sortHandler(_ req: Request)
        -> EventLoopFuture<[Acronym]> {
        Acronym.query(on: req.db)
            .sort(\.$short, .ascending)
            .all()
    }
}

struct CreateAcronymData: Content { // Content is kind like Codable in swift
    let short: String
    let long: String
}
