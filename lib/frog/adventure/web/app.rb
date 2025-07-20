# frozen_string_literal: true

require "sinatra/base"
require "json"
require "dotenv/load"

module Frog
  module Adventure
    module Web
      class App < Sinatra::Base
        # Configure Sinatra
        configure do
          set :public_folder, File.expand_path("../../../../public", __dir__)
          set :views, File.expand_path("../../../../views", __dir__)
          enable :sessions
          set :session_secret, ENV.fetch("SESSION_SECRET") { SecureRandom.hex(64) }
        end

        # Configure for development
        configure :development do
          enable :logging
          enable :dump_errors
          enable :show_exceptions
        end

        # Homepage
        get "/" do
          erb :index
        end

        # API endpoint for game state
        get "/api/game/state" do
          content_type :json
          # TODO: Implement game state retrieval
          { status: "ok", message: "Game state endpoint" }.to_json
        end

        # API endpoint for new game
        post "/api/game/new" do
          content_type :json
          # TODO: Implement new game creation
          { status: "ok", message: "New game created" }.to_json
        end

        # API endpoint for game actions
        post "/api/game/action" do
          content_type :json
          # TODO: Implement game action processing
          { status: "ok", message: "Action processed" }.to_json
        end

        # Health check endpoint
        get "/health" do
          content_type :json
          { status: "healthy", version: VERSION }.to_json
        end
      end
    end
  end
end