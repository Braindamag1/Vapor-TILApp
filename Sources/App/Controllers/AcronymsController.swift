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
        acronymsRoutes.post(use: createHandler)
        acronymsRoutes.get(use: getAllHandler)
        acronymsRoutes.get(":acronymID", use: getHandler)
        acronymsRoutes.get(":acronymID", "user", use: getUserHandler)
        acronymsRoutes.put(":acronymID", use: updateHandler)
        acronymsRoutes.delete(":acronymID", use: deleteHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("sorted", use: sortHandler)
    }

    // C- create - POST
    func createHandler(_ req: Request) throws
        -> EventLoopFuture<Acronym> {
        let dto = try req.content.decode(CreateAcronymData.self)
        let acronym = Acronym(createAcronymData: dto)
        return acronym.save(on: req.db)
            .map { _ in
                acronym
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
        -> EventLoopFuture<User> {
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.$user.get(on: req.db)
            }
    }

    // U- update - PUT
    func updateHandler(_ req: Request) throws
        -> EventLoopFuture<Acronym> {
        let updateDTO = try req.content.decode(CreateAcronymData.self)
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = updateDTO.short
                acronym.long = updateDTO.long
                acronym.$user.id = updateDTO.userID
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
    let userID: UUID
}
