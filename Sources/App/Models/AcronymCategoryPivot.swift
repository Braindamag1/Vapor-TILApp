//
//  File.swift
//  
//
//  Created by YJ.Lee on 2022/5/9.
//

import Vapor
import Fluent

final class AcronymCategoryPivot: Model {
    static var schema: String = "acronym-category-pivot"
    
    @ID
    var id: UUID?
    
    @Parent(key: "acronymID")
    var acronym:Acronym
    
    @Parent(key: "categoryID")
    var category: Category
    
    init() {}
    
    init(id: UUID? = nil,
         acronym:Acronym,
         category:Category) throws {
        self.id = id
        self.$acronym.id = try acronym.requireID()
        self.$category.id = try category.requireID()
    }
}
