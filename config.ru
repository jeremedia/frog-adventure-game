# frozen_string_literal: true

require "bundler/setup"
require "frog/adventure/web"

# Load environment variables in development
if ENV["RACK_ENV"] == "development"
  require "dotenv/load"
end

# Configure Rack middleware
use Rack::Deflater # Enable gzip compression
use Rack::ConditionalGet # Support conditional GET requests
use Rack::ETag # Add ETag headers

# Add request ID tracking - disabled due to Rack::Lint header case issue
# if defined?(Rack::RequestId)
#   use Rack::RequestId
# end
# Host authorization disabled - handled in Sinatra app configuration
# Enable runtime monitoring in production
if ENV["RACK_ENV"] == "production" && defined?(Rack::Runtime)
  use Rack::Runtime
end

# Static file serving configuration
if ENV["SERVE_STATIC_FILES"] == "true"
  use Rack::Static,
      urls: ["/css", "/js", "/images", "/fonts"],
      root: "public",
      header_rules: [
        [:all, { "Cache-Control" => "public, max-age=3600" }],
        [%w[css js], { "Cache-Control" => "public, max-age=86400" }]
      ]
end

# Run the Sinatra application
run Frog::Adventure::Web.app