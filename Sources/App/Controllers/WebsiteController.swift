import Vapor
import Leaf
import Authentication

struct WebsiteController: RouteCollection {
  func boot(router: Router) throws {
    let authSessionRoutes = router.grouped(User.authSessionsMiddleware())
    authSessionRoutes.get(use: indexHandler)
    authSessionRoutes.get("postList", use: postListHandler)
    authSessionRoutes.get("categories", use: categoryHandler)
    authSessionRoutes.get("posts", Post.parameter, use: postHandler)
    authSessionRoutes.get("about", use: aboutHandler)
    
    authSessionRoutes.get("login", use: loginHandler)
    authSessionRoutes.post("login", use: loginPostHandler)
    
    let protectedRoutes = authSessionRoutes.grouped(RedirectMiddleware<User>(path: "/login"))
    protectedRoutes.get("postEdit", use: postEditHandler)
    protectedRoutes.post("createPost", use: createPostHandler)
    protectedRoutes.get("dashboard", use: dashBoardHandler)
  }
  
  func indexHandler(_ req: Request) throws -> Future<View> {
    return Post.query(on: req).all().flatMap(to: View.self) { posts in
      let postContext = posts.count > 5 ? Array(posts[0...4]) : posts
      let context = IndexContent(title: "Homepage", posts: posts.isEmpty ? nil : postContext)
      return try req.leaf().render("index", context)
    }
  }
  
  func postListHandler(_ req: Request) throws -> Future<View> {
    return Post.query(on: req).all().flatMap(to: View.self) { posts in
      let context = IndexContent(title: "post list", posts: posts.isEmpty ? nil : posts)
      return try req.leaf().render("postList", context)
    }
  }
  
  func categoryHandler(_ req: Request) throws -> Future<View> {
    return Category.query(on: req).all().flatMap(to: View.self) { categories in
      let context = CategoryContext(categories: categories.isEmpty ? nil : categories)
      return try req.leaf().render("category", context)
    }
  }
  
  func postHandler(_ req: Request) throws -> Future<View> {
    return try req.parameters.next(Post.self).flatMap(to: View.self) { post in
      return post.user.get(on: req).flatMap(to: View.self) { user in
        return try post.categories.query(on: req).all().flatMap(to: View.self) { categories in
          let context = PostsContext(post: post,
                                     user: user,
                                     categories: categories.isEmpty ? nil : categories)
          return try req.leaf().render("post", context)
        }
      }
    }
  }
  
  func aboutHandler(_ req: Request) throws -> Future<View> {
    let context = EmptyContext()
    return try req.leaf().render("about", context)
  }
  
  func postEditHandler(_ req: Request) throws -> Future<View> {
    return Category.query(on: req).all().flatMap(to: View.self) { categories in
      let context = CategoryContext(categories: categories.isEmpty ? nil : categories)
      return try req.leaf().render("admin/postEdit", context)
    }
  }
  
  func createPostHandler(_ req: Request) throws -> Future<Response> {
    return try req.content.decode(PostContext.self).flatMap(to: Response.self) { data in
      let user = try req.requireAuthenticated(User.self)
      let post = Post(title: data.title,
                      subTitle: data.subTitle,
                      body: data.body,
                      creatorID: try user.requireID())
      return post.save(on: req).map(to: Response.self) { post in
        guard let id = post.id else {
          return req.redirect(to: "/")
        }
        return req.redirect(to: "posts/\(id)")
      }
    }
  }
  
  func loginHandler(_ req: Request) throws -> Future<View> {
    let context = LoginContext(title: "Log In")
    return try req.leaf().render("login", context)
  }
  
  func loginPostHandler(_ req: Request) throws -> Future<Response> {
    return try req.content.decode(LoginPostData.self).flatMap(to: Response.self) { data in
      let verifier = try req.make(BCryptDigest.self)
      return User.authenticate(username: data.userID,
                               password: data.password,
                               using: verifier,
                               on: req).map(to: Response.self) { user in
                                guard let user = user else {
                                  return req.redirect(to: "/login")
                                }
                                try req.authenticateSession(user)
                                return req.redirect(to: "/")
      }
    }
  }
  
  func dashBoardHandler(_ req: Request) throws -> Future<View> {
    let context = EmptyContext()
    return try req.leaf().render("admin/dashboard", context)
  }
}

extension Request {
  func leaf() throws -> LeafRenderer {
    return try self.make(LeafRenderer.self)
  }
}

struct EmptyContext: Encodable {
  
}

struct UserContext: Content {
  let name: String
  let userID: String
  let password: String
}

struct IndexContent: Encodable {
  let title: String
  let posts: [Post]?
}

struct CategoryContext: Encodable {
  let categories: [Category]?
}

struct PostsContext: Encodable {
  let post: Post
  let user: User
  let categories: [Category]?
}

struct PostContext: Content {
  let title: String
  let subTitle: String
  let body: String
  let createdAt: Date?
  let updatedAt: Date?
}

struct LoginContext: Encodable {
  let title: String
}

struct LoginPostData: Content {
  let userID: String
  let password: String
}
