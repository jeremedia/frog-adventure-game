# frozen_string_literal: true

module Frog
  module Adventure
    module Web
      # Routes module to organize application routes
      module Routes
        def self.included(app)
          app.class_eval do
            # Homepage and static pages
            get "/" do
              @title = "Frog Adventure"
              @game_stats = fetch_game_stats
              erb :index
            end
            
            get "/about" do
              @title = "About Frog Adventure"
              erb :about
            end
            
            get "/how-to-play" do
              @title = "How to Play"
              erb :how_to_play
            end
            
            # Game routes
            namespace "/game" do
              # New game page
              get "/new" do
                @title = "New Game"
                erb :"game/new"
              end
              
              # Load game page
              get "/load" do
                @title = "Load Game"
                @saved_games = fetch_saved_games(session[:player_id])
                erb :"game/load"
              end
              
              # Play game
              get "/play/:game_id" do
                @game = load_game(params[:game_id])
                halt 404, "Game not found" unless @game
                
                @title = "Playing: #{@game[:title]}"
                erb :"game/play"
              end
            end
            
            # API routes
            namespace "/api" do
              # API documentation
              get "/" do
                content_type :json
                {
                  version: "1.0",
                  endpoints: {
                    health: "/health",
                    game: {
                      state: "GET /api/game/:id/state",
                      new: "POST /api/game/new",
                      action: "POST /api/game/:id/action",
                      save: "POST /api/game/:id/save",
                      load: "GET /api/game/:id"
                    },
                    player: {
                      profile: "GET /api/player/profile",
                      games: "GET /api/player/games"
                    }
                  }
                }.to_json
              end
              
              namespace "/game" do
                # Create new game
                post "/new" do
                  content_type :json
                  
                  begin
                    game_params = JSON.parse(request.body.read)
                    game = create_new_game(game_params)
                    
                    status 201
                    { 
                      status: "success", 
                      game_id: game[:id],
                      message: "New game created successfully"
                    }.to_json
                  rescue JSON::ParserError
                    status 400
                    { status: "error", message: "Invalid JSON" }.to_json
                  rescue => e
                    status 500
                    { status: "error", message: e.message }.to_json
                  end
                end
                
                # Get game state
                get "/:id/state" do
                  content_type :json
                  
                  game = load_game(params[:id])
                  if game
                    { status: "success", game: game }.to_json
                  else
                    status 404
                    { status: "error", message: "Game not found" }.to_json
                  end
                end
                
                # Process game action
                post "/:id/action" do
                  content_type :json
                  
                  begin
                    action_params = JSON.parse(request.body.read)
                    result = process_game_action(params[:id], action_params)
                    
                    if result[:success]
                      { status: "success", result: result }.to_json
                    else
                      status 422
                      { status: "error", message: result[:error] }.to_json
                    end
                  rescue JSON::ParserError
                    status 400
                    { status: "error", message: "Invalid JSON" }.to_json
                  rescue => e
                    status 500
                    { status: "error", message: e.message }.to_json
                  end
                end
                
                # Save game
                post "/:id/save" do
                  content_type :json
                  
                  if save_game(params[:id])
                    { status: "success", message: "Game saved successfully" }.to_json
                  else
                    status 500
                    { status: "error", message: "Failed to save game" }.to_json
                  end
                end
                
                # Load specific game
                get "/:id" do
                  content_type :json
                  
                  game = load_game(params[:id])
                  if game
                    { status: "success", game: game }.to_json
                  else
                    status 404
                    { status: "error", message: "Game not found" }.to_json
                  end
                end
              end
              
              namespace "/player" do
                # Get player profile
                get "/profile" do
                  content_type :json
                  
                  if session[:player_id]
                    profile = fetch_player_profile(session[:player_id])
                    { status: "success", profile: profile }.to_json
                  else
                    status 401
                    { status: "error", message: "Not authenticated" }.to_json
                  end
                end
                
                # Get player's games
                get "/games" do
                  content_type :json
                  
                  if session[:player_id]
                    games = fetch_player_games(session[:player_id])
                    { status: "success", games: games }.to_json
                  else
                    status 401
                    { status: "error", message: "Not authenticated" }.to_json
                  end
                end
              end
            end
            
            # Health check endpoint
            get "/health" do
              content_type :json
              { 
                status: "healthy", 
                version: VERSION,
                environment: Config.environment,
                timestamp: Time.now.iso8601
              }.to_json
            end
            
            # Helpers
            helpers do
              # Game-related helpers
              def create_new_game(params)
                # TODO: Implement game creation logic
                { id: SecureRandom.uuid, title: params["title"] || "New Adventure" }
              end
              
              def load_game(game_id)
                # TODO: Implement game loading logic
                nil
              end
              
              def save_game(game_id)
                # TODO: Implement game saving logic
                true
              end
              
              def process_game_action(game_id, action)
                # TODO: Implement action processing logic
                { success: true, message: "Action processed" }
              end
              
              def fetch_game_stats
                # TODO: Implement stats fetching
                { total_games: 0, active_players: 0 }
              end
              
              def fetch_saved_games(player_id)
                # TODO: Implement saved games fetching
                []
              end
              
              def fetch_player_profile(player_id)
                # TODO: Implement player profile fetching
                { id: player_id, name: "Player" }
              end
              
              def fetch_player_games(player_id)
                # TODO: Implement player games fetching
                []
              end
            end
          end
        end
      end
    end
  end
end