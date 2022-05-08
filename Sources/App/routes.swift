import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { _ in
        "It works!"
    }

    app.get("hello") { _ -> String in
        "Hello, world!"
    }

    // Create-POST
    app.post("api", "acronyms") { req -> EventLoopFuture<Acronym> in
        let acronym = try req.content.decode(Acronym.self)
        return acronym.save(on: req.db)
            .map {
                acronym
            }
    }
    // Retrieve-GET
    app.get("api", "acronyms") { req -> EventLoopFuture<[Acronym]> in
        Acronym.query(on: req.db)
            .all()
    }
    app.get("api", "acronyms", ":acronymID") { req -> EventLoopFuture<Acronym> in
        Acronym.find(req.parameters.get("acronymID"),
                     on: req.db)
            .unwrap(or: Abort(.notFound))
    }

    // Update-PUT
    app.put("api", "acronyms", ":acronymID") { req -> EventLoopFuture<Acronym> in
        let update = try req.content.decode(Acronym.self)
        return Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.short = update.short
                acronym.long = update.long
                return acronym.save(on: req.db).map { _ in
                    acronym
                }
            }
    }
    // Delete - Delete
    app.delete("api","acronyms",":acronymID") { req->EventLoopFuture<HTTPStatus> in
        Acronym.find(req.parameters.get("acronymID"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap { acronym in
                acronym.delete(on: req.db)
                    .transform(to: .noContent)
            }
    }
}
