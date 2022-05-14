//
//  File.swift
//
//
//  Created by YJ.Lee on 2022/5/7.
//

import Fluent
import Vapor

final class Acronym: Model {
    static let schema = "acronyms"

    @ID
    var id: UUID?

    @Field(key: "short")
    var short: String

    @Field(key: "long")
    var long: String

    @Parent(key: "userID")
    var user:User
    init() {}

    @Siblings(through: AcronymCategoryPivot.self,
              from: \.$acronym,
              to: \.$category)
    var categories: [Category]
    
    init(id: UUID? = nil,
         short: String,
         long: String,
         userID:User.IDValue) {
        self.id = id
        self.short = short
        self.long = long
        self.$user.id = userID
    }
}

extension Acronym: Content {
    
}
