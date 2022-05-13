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

    @Field(key: "password")
    var password: String

    @Children(for: \.$user)
    var acronuyms: [Acronym]
    init() {}

    init(id: UUID? = nil,
         name: String,
         username: String,
         password: String) {
        self.id = id
        self.name = name
        self.username = username
        self.password = password
    }
    
    final class Public: Content {
        var id: UUID?
        var name: String
        var username: String
        init(id: UUID?, name: String, username: String) {
            self.id = id
            self.name = name
            self.username = username
        }
    }
}

extension User: Content {
}

extension User {
    func convertToPublic()->Public {
        return User.Public.init(id: id, name: name, username: username)
    }
}

extension EventLoopFuture where Value: User {
    func convertToPublic()->EventLoopFuture<User.Public> {
        return self.map { user in
            return user.convertToPublic()
        }
    }
}

extension Collection where Element: User {
    func convertToPublic()->[User.Public] {
        return self.map({$0.convertToPublic()})
    }
}

extension EventLoopFuture where Value == Array<User> {
    func convertToPublic()->EventLoopFuture<[User.Public]> {
        return self.map({$0.convertToPublic()})
    }
}

