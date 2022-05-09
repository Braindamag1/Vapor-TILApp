//
//  File.swift
//  
//
//  Created by YJ.Lee on 2022/5/7.
//

import Fluent

struct CreateAcronym:Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms")
            .id()
            .field("short", .string, .required)
            .field("long", .string, .required)
            .field("userID", .uuid, .required)
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronyms")
            .delete()
    }
}
