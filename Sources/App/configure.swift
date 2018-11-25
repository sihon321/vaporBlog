import FluentPostgreSQL
import Vapor
import Leaf
import LeafMarkdown
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentProvider())
    try services.register(PostgreSQLProvider())
    try services.register(LeafProvider())
    var tags = LeafTagConfig.default()
    tags.use(Markdown(), as: "markdown")
    services.register(tags)
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
    let corsConfiguration = CORSMiddleware.Configuration(
      allowedOrigin: .all,
      allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
      allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
    )
    let corsMiddleware = CORSMiddleware(configuration: corsConfiguration)
    middlewares.use(corsMiddleware)
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)
    
    // Configure a database
    var databases = DatabasesConfig()
  
    let database = PostgreSQLDatabase(config: PostgreSQLDatabaseConfig(hostname: "192.168.99.100",
                                                                       port: 32768,
                                                                       username: "test",
                                                                       database: "postgres",
                                                                       password: "test",
                                                                       transport: .cleartext))
    databases.add(database: database, as: .psql)
    services.register(databases)
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
}

