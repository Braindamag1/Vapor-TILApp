//
//  File.swift
//  
//
//  Created by YJ.Lee on 2022/5/9.
//

import Fluent
struct CreateAcronymCategoryPivot:Migration {
    
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronym-category-pivot")
            .id()
            .field("acronymID", .uuid, .required,.references("acronyms", .id, onDelete: .cascade)) //连续传递删除 删除model 关系也会删除
            .field("categoryID", .uuid, .required,.references("categories", .id, onDelete: .cascade)) //连续删除传递  删除model 关系也会删除
            .create()
    }
    
    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema("acronym-category-pivot").delete()
    }
}
