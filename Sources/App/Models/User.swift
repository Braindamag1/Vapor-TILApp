//
//  File.swift
//
//
//  Created by YJ.Lee on 2022/5/8.
//

import Fluent
import Vapor

final class User: Model {
    static let schema: String = "users" // 表名
    @ID
    var id: UUID?

    @Field(key: "name") // profject 可以用\.$ key path访问
    var name: String

    @Field(key: "username")
    var username: String

    init() {}
    
    init(id:UUID? = nil,
         name:String,
         username:String) {
        self.id = id
        self.name = name
        self.username = username
    }
}

extension User: Content {
}
