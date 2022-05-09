import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { _ in
        "It works!"
    }
    
    let usersController = UsersController()
    try app.register(collection: usersController)
    let acronymsController = AcronymsController()
    try app.register(collection: acronymsController)
    let categoriesController = CategoriesController()
    try app.register(collection: categoriesController)
}
