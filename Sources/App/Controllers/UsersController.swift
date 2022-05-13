//
//  File.swift
//
//
//  Created by YJ.Lee on 2022/5/8.
//

import Vapor

struct UsersController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
       
        let usersRoute = routes.grouped("api", "users")
        usersRoute.post(use: createHandler)
        usersRoute.get(use: getAllHandler)
        usersRoute.get(":userID", use: getHandler)
        usersRoute.get(":userID","acronyms", use: getAcronymsHandler)
    }

    // C- Create POST
    func createHandler(_ req: Request) throws
    -> EventLoopFuture<User.Public> {
        let user = try req.content.decode(User.self)
            user.password =  try  Bcrypt.hash(user.password)
        return user.save(on: req.db)
            .map { _ in
                user.convertToPublic()
            }
    }

    // R - Retrieve GET
    func getAllHandler(_ req: Request)
    -> EventLoopFuture<[User.Public]> {
        User.query(on: req.db)
            .all()
            .convertToPublic()
    }

    func getAcronymsHandler(_ req: Request)
        -> EventLoopFuture<[Acronym]> {
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap({
                $0.$acronuyms.get(on: req.db)
            })
    }

    func getHandler(_ req: Request)
    -> EventLoopFuture<User.Public> {
        // find 与 query 有什么区别吗
        User.find(req.parameters.get("userID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .convertToPublic()
    }
}
