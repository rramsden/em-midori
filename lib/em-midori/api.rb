##
# This class provides methods to be inherited as route definition.
class Midori::API
  class << self
    attr_accessor :routes, :scope_middlewares
    def class_initialize
      @routes = {
        GET: [],
        POST: [],
        PUT: [],
        DELETE: [],
        OPTIONS: [],
        LINK: [],
        UNLINK: [],
        WEBSOCKET: [],
        EVENTSOURCE: [],
        MOUNT: []
      }
      @scope_middlewares = []
      @temp_middlewares = []
    end

    # Add GET method as a DSL for route definition
    # @param [ String ] path Accepts as part of path in route definition
    # @yield what to run when route matched
    # @return [ nil ] nil
    # @example String as router
    #   get '/' do
    #      puts 'Hello World'
    #   end
    def get(path, &block) end

    # Add POST method as a DSL for route definition
    # @param [ String ] path Accepts as part of path in route definition
    # @yield what to run when route matched
    # @return [ nil ] nil
    # @example String as router
    #   post '/' do
    #      puts 'Hello World'
    #   end
    def post(path, &block) end

    # Add PUT method as a DSL for route definition
    # @param [ String ] path Accepts as part of path in route definition
    # @yield what to run when route matched
    # @return [ nil ] nil
    # @example String as router
    #   put '/' do
    #      puts 'Hello World'
    #   end
    def put(path, &block) end

    # Add DELETE method as a DSL for route definition
    # @param [ String ] path Accepts as part of path in route definition
    # @yield what to run when route matched
    # @return [ nil ] nil
    # @example String as router
    #   delete '/' do
    #      puts 'Hello World'
    #   end
    def delete(path, &block) end

    # Add OPTIONS method as a DSL for route definition
    # @param [ String ] path Accepts as part of path in route definition
    # @return [ nil ] nil
    # @example String as router
    #   options '/' do
    #      puts 'Hello World'
    #   end
    def options(path, &block) end

    # Add LINK method as a DSL for route definition
    # @param [ String ] path Accepts as part of path in route definition
    # @yield what to run when route matched
    # @return [ nil ] nil
    # @example String as router
    #   link '/' do
    #      puts 'Hello World'
    #   end
    def link(path, &block) end

    # Add UNLINK method as a DSL for route definition
    # @param [ String ] path Accepts as part of path in route definition
    # @yield what to run when route matched
    # @return [ nil ] nil
    # @example String as router
    #   unlink '/' do
    #      puts 'Hello World'
    #   end
    def unlink(path, &block) end

    # Add WEBSOCKET method as a DSL for route definition
    # @param [ String ] path Accepts as part of path in route definition
    # @yield what to run when route matched
    # @return [ nil ] nil
    # @example String as router
    #   websocket '/' do
    #      puts 'Hello World'
    #   end
    def websocket(path, &block) end

    # Add EVENTSOURCE method as a DSL for route definition
    # @param [ String ] path Accepts as part of path in route definition
    # @return [ nil ] nil
    # @example String as router
    #   eventsource '/' do
    #      puts 'Hello World'
    #   end
    def eventsource(path, &block) end
    
    # Mount a route prefix with another API defined
    # @param [String] prefix prefix of the route String
    # @param [Class] api inherited from Midori::API
    # @return [nil] nil
    def mount(prefix, api)
      raise ArgumentError if prefix == '/' # Cannot mount route API
      @routes[:MOUNT] << [prefix, api]
    end

    # Implementation of route DSL
    # @param [ String ] method HTTP method
    # @param [ String, Regexp ] path path definition
    # @param [ Proc ] block process to run when route matched
    # @return [ nil ] nil
    def add_route(method, path, block)
      # Argument check
      raise ArgumentError unless path.is_a?String

      # Insert route to routes
      route = Midori::Route.new(method, path, block)
      route.middlewares = @scope_middlewares + @temp_middlewares
      @routes[method] << route

      # Clean up temp middleware
      @temp_middlewares = []
      nil
    end

    # Use a middleware in the all routes
    # @param [Class] middleware Inherited from +Midori::Middleware+
    # @return [nil] nil
    def use(middleware, *args)
      middleware = middleware.new(*args)
      CleanRoom.class_exec { middleware.helper }
      @scope_middlewares << middleware
      nil
    end

    def filter(middleware, *args)
      middleware = middleware.new(*args)
      CleanRoom.class_exec { middleware.helper }
      @temp_middlewares << middleware
      nil
    end

    # Helper block for defining methods in APIs
    # @yield define what to run in CleanRoom
    def helper(&block)
      Midori::CleanRoom.class_exec(&block)
    end

    def inherited(subclass)
      subclass.class_initialize
    end
  end

  private_class_method :add_route

  # Constants of supported methods in route definition
  METHODS = %w(get post put delete options link unlink websocket eventsource).freeze

  # Magics to fill DSL methods through dynamically class method definition
  METHODS.each do |method|
    define_singleton_method(method) do |*args, &block|
      add_route(method.upcase.to_sym, args[0], block) # args[0]: path
    end
  end
end
