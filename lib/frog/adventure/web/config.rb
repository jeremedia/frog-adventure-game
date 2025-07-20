# frozen_string_literal: true

module Frog
  module Adventure
    module Web
      # Configuration module for environment-specific settings
      module Config
        extend self
        
        # Load configuration for the current environment
        def load!
          @config = defaults.merge(environment_config)
        end
        
        # Access configuration values
        def [](key)
          @config ||= load!
          @config[key]
        end
        
        # Get all configuration
        def to_h
          @config ||= load!
          @config.dup
        end
        
        # Current environment
        def environment
          ENV.fetch("RACK_ENV", "development")
        end
        
        # Check if in development
        def development?
          environment == "development"
        end
        
        # Check if in production
        def production?
          environment == "production"
        end
        
        # Check if in test
        def test?
          environment == "test"
        end
        
        private
        
        # Default configuration values
        def defaults
          {
            # Server settings
            port: ENV.fetch("PORT", 4567).to_i,
            host: ENV.fetch("HOST", "0.0.0.0"),
            
            # Session settings
            session_secret: ENV.fetch("SESSION_SECRET") { SecureRandom.hex(64) },
            session_expire: 2592000, # 30 days
            
            # Redis settings
            redis_url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
            redis_pool_size: ENV.fetch("REDIS_POOL_SIZE", 5).to_i,
            
            # LLM settings
            llm_provider: ENV.fetch("LLM_PROVIDER", "openai"),
            llm_api_key: ENV.fetch("LLM_API_KEY", nil),
            llm_model: ENV.fetch("LLM_MODEL", "gpt-4"),
            llm_temperature: ENV.fetch("LLM_TEMPERATURE", 0.8).to_f,
            llm_max_tokens: ENV.fetch("LLM_MAX_TOKENS", 1000).to_i,
            
            # Game settings
            game_session_timeout: ENV.fetch("GAME_SESSION_TIMEOUT", 3600).to_i, # 1 hour
            game_max_active_sessions: ENV.fetch("GAME_MAX_ACTIVE_SESSIONS", 1000).to_i,
            
            # Feature flags
            enable_analytics: ENV.fetch("ENABLE_ANALYTICS", "false") == "true",
            enable_debug_mode: ENV.fetch("ENABLE_DEBUG_MODE", "false") == "true",
            
            # Security settings
            force_ssl: ENV.fetch("FORCE_SSL", "false") == "true",
            cors_origins: ENV.fetch("CORS_ORIGINS", "*"),
            
            # Logging
            log_level: ENV.fetch("LOG_LEVEL", "info").to_sym
          }
        end
        
        # Environment-specific configuration
        def environment_config
          case environment
          when "development"
            {
              log_level: :debug,
              enable_debug_mode: true,
              force_ssl: false
            }
          when "production"
            {
              log_level: :info,
              enable_debug_mode: false,
              force_ssl: true
            }
          when "test"
            {
              log_level: :error,
              enable_debug_mode: false,
              force_ssl: false,
              session_secret: "test-secret-key"
            }
          else
            {}
          end
        end
      end
    end
  end
end