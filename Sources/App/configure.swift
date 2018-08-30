import FluentPostgreSQL
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentProvider())
    try services.register(PostgreSQLProvider())
    try services.register(LeafProvider())
    try services.register(AuthenticationProvider())
    
    /// Configure migrations
    var migrations = MigrationConfig()
    User.Public.defaultDatabase = .psql
    User.defaultDatabase = .psql
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Post.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: PostCategoryPivot.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    services.register(migrations)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    
    // Configure a database
    var databases = DatabasesConfig()
    let database = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(hostname: "localhost",
                                                                       port: 32768,
                                                                       username: "sihoon",
                                                                       database: "postgres",
                                                                       password: "tlgnsdl1",
                                                                       transport: .cleartext))
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}

