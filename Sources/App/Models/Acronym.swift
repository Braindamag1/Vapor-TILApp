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

    init() {}

    init(id: UUID? = nil,
         short: String,
         long: String) {
        self.id = id
        self.short = short
        self.long = long
    }
}

extension Acronym: Content {
    
}