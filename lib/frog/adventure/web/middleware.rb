# frozen_string_literal: true

module Frog
  module Adventure
    module Web
      # Middleware configuration for the Sinatra app
      module Middleware
        def self.configure(app)
          # Request ID middleware for tracking - disabled due to Rack::Lint header case issue
          # app.use Rack::RequestId if defined?(Rack::RequestId)
          
          # CORS middleware for API endpoints - temporarily disabled for debugging
          # app.use Rack::Cors do
          #   allow do
          #     origins ENV.fetch("CORS_ORIGINS", "*").split(",")
          #     resource "/api/*",
          #       headers: :any,
          #       methods: [:get, :post, :put, :patch, :delete, :options]
          #   end
          # end if defined?(Rack::Cors)
          
          # Request throttling - temporarily disabled for debugging
          # if defined?(Rack::Attack)
          #   app.use Rack::Attack
          #   
          #   Rack::Attack.throttle("requests by ip", limit: 60, period: 60) do |request|
          #     request.ip
          #   end
          #   
          #   Rack::Attack.throttle("api requests by ip", limit: 20, period: 60) do |request|
          #     request.ip if request.path.start_with?("/api")
          #   end
          # end
          
          # Custom middleware for request logging
          app.use RequestLogger
          
          # Game session middleware
          app.use GameSessionMiddleware
        end
      end
      
      # Custom middleware for request logging
      class RequestLogger
        def initialize(app)
          @app = app
          @logger = Logger.new(STDOUT)
        end
        
        def call(env)
          start_time = Time.now
          request = Rack::Request.new(env)
          
          @logger.info "Started #{request.request_method} \"#{request.path}\" for #{request.ip}"
          
          status, headers, response = @app.call(env)
          
          duration = Time.now - start_time
          @logger.info "Completed #{status} in #{(duration * 1000).round(2)}ms"
          
          [status, headers, response]
        end
      end
      
      # Middleware for managing game sessions
      class GameSessionMiddleware
        def initialize(app)
          @app = app
        end
        
        def call(env)
          request = Rack::Request.new(env)
          
          # Initialize game session if not present
          if request.session[:game_id].nil? && request.path.start_with?("/api/game")
            request.session[:game_id] = SecureRandom.uuid
            request.session[:created_at] = Time.now.to_i
          end
          
          @app.call(env)
        end
      end
    end
  end
end