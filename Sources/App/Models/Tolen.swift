//
//  File.swift
//
//
//  Created by YJ.Lee on 2022/5/13.
//

import Fluent
import Vapor

final class Token: Model {
    static let schema: String = "tokens"
    @ID
    var id: UUID?
    
    @Field(key: "value")
    var value:String
    
    @Parent(key: "userID")
    var user:User
    
    init() {}
    
    init(id:UUID? = nil, value:String, userID: User.IDValue) {
        self.id = id
        self.value = value
        self.$user.id = userID
    }
}

extension Token: Content {
}
