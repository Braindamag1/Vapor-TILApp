import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { _ in
        "It works!"
    }

    let acronymsController = AcronymsController()
    try app.register(collection: acronymsController)
    
}
