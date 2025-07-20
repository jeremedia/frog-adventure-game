# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "sinatra/json"
require "sinatra/cookies"
require "sinatra/namespace"
require "rack/protection"
require "rack/session/cookie"
require "rack/cors"
require "rack/request_id"
require "json"
require "logger"
require "securerandom"
require "dotenv/load"

require_relative "routes"
require_relative "middleware"

module Frog
  module Adventure
    module Web
      class App < Sinatra::Base
        # Register extensions
        register Sinatra::Namespace
        
        # Apply middleware configuration
        Middleware.configure(self)
        
        # Include routes
        include Routes
        
        # Configure Sinatra
        configure do
          set :public_folder, File.expand_path("../../../../public", __dir__)
          set :views, File.expand_path("../../../../views", __dir__)
          set :root, File.expand_path("../../../..", __dir__)
          set :server, %w[puma thin webrick]
          set :port, ENV.fetch("PORT", 4567).to_i
          set :bind, ENV.fetch("HOST", "0.0.0.0")
          
          # Session configuration
          enable :sessions
          set :session_secret, ENV.fetch("SESSION_SECRET") { SecureRandom.hex(64) }
          set :sessions, 
              key: "frog.adventure.session",
              expire_after: 2592000, # 30 days
              same_site: :lax,
              httponly: true
          
          # Security settings
          enable :protection
          set :protection, except: [:json_csrf]
          
          # Logging
          enable :logging
          set :logger, Logger.new(STDOUT)
          
          # Static file cache control
          set :static_cache_control, [:public, max_age: 3600]
        end

        # Configure for development
        configure :development do
          register Sinatra::Reloader
          also_reload "lib/**/*.rb"
          
          enable :dump_errors
          enable :show_exceptions
          enable :raise_errors
          
          set :show_exceptions, :after_handler
          
          # Development-specific logging
          logger.level = Logger::DEBUG
        end
        
        # Configure for production
        configure :production do
          disable :dump_errors
          disable :show_exceptions
          enable :raise_errors
          
          # Production logging
          logger.level = Logger::INFO
          
          # Force SSL in production
          use Rack::SSL if ENV["FORCE_SSL"] == "true"
        end
        
        # Configure for test
        configure :test do
          disable :logging
          enable :dump_errors
          enable :raise_errors
        end

        # Routes are included from the Routes module
        
        # Error handlers
        error 404 do
          content_type :json
          status 404
          json error: "Not Found", message: "The requested resource could not be found"
        end
        
        error 500 do
          content_type :json
          status 500
          json error: "Internal Server Error", message: "An unexpected error occurred"
        end
        
        error do
          content_type :json
          status 500
          json error: "Server Error", message: env['sinatra.error'].message
        end
      end
    end
  end
end