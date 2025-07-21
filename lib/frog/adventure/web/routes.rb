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
            
            # Game page (main game UI)
            get "/game" do
              @title = "Frog Adventure - Game"
              erb :game
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
              
              # Frog companion routes
              namespace "/frog" do
                # Generate random frog companion
                post "/generate" do
                  content_type :json
                  
                  begin
                    # Use LLM to generate unique frog
                    llm_client = Frog::Adventure::Web::LLMClient.new
                    request_data = JSON.parse(request.body.read) rescue {}
                    frog_type = request_data["frog_type"] || nil
                    
                    # Generate frog using LLM
                    generated_frog = llm_client.generate_frog(frog_type: frog_type)
                    
                    if generated_frog
                      # Convert Frog model to hash format expected by frontend
                      frog_data = {
                        name: generated_frog.name,
                        type: generated_frog.frog_type,
                        ability: generated_frog.ability,
                        description: generated_frog.description,
                        energy: generated_frog.energy,
                        happiness: generated_frog.happiness,
                        stats: generated_frog.stats,
                        traits: generated_frog.traits,
                        species: generated_frog.species,
                        backstory: generated_frog.backstory
                      }
                      
                      { 
                        status: "success", 
                        frog: frog_data 
                      }.to_json
                    else
                      # Fallback if LLM fails completely
                      fallback_frogs = [
                        {
                          name: "Sparky",
                          type: "Tree Frog",
                          ability: "Lightning Leap", 
                          description: "A vibrant green tree frog with electric blue toe pads that sparkle with energy",
                          energy: 100,
                          happiness: 75,
                          stats: { strength: 8, agility: 18, intelligence: 12, magic: 14, luck: 13 },
                          traits: ["Energetic", "Brave"],
                          species: "Electrophorus Hopicus",
                          backstory: "Once struck by magical lightning while climbing the Great Oak, gained incredible speed and electrical powers"
                        }
                      ]
                      
                      selected_frog = fallback_frogs.sample
                      
                      { 
                        status: "success", 
                        frog: selected_frog,
                        warning: "Using fallback frog due to LLM error"
                      }.to_json
                    end
                  rescue => e
                    puts "Frog generation error: #{e.message}"
                    status 500
                    { status: "error", message: "Failed to generate frog" }.to_json
                  end
                end
              end
              
              # Adventure routes
              namespace "/adventure" do
                # Start a new adventure
                post "/start" do
                  content_type :json
                  
                  begin
                    # Use LLM to generate adventure scenario
                    llm_client = Frog::Adventure::Web::LLMClient.new
                    request_data = JSON.parse(request.body.read) rescue {}
                    frog_stats = request_data["frog_stats"] || {}
                    
                    scenario = llm_client.generate_adventure_scenario(frog_stats: frog_stats)
                    
                    if scenario
                      { 
                        status: "success", 
                        scenario: scenario.to_h
                      }.to_json
                    else
                      # Fallback to hardcoded scenarios if LLM fails
                      scenarios = [
                    {
                      id: SecureRandom.uuid,
                      title: "The Glowing Mushroom Grove",
                      description: "Your frog discovers a grove where bioluminescent mushrooms cast an eerie blue light. The air shimmers with magical energy, and you hear soft whispers coming from the fungi. Some mushrooms pulse brighter when your frog approaches.",
                      choices: [
                        { id: 1, text: "Touch the brightest mushroom", risk: "high" },
                        { id: 2, text: "Listen carefully to the whispers", risk: "medium" },
                        { id: 3, text: "Collect some fallen spores", risk: "low" }
                      ]
                    },
                    {
                      id: SecureRandom.uuid,
                      title: "The Singing Stream",
                      description: "A crystal-clear stream flows through the forest, its water creating melodic sounds as it flows over rocks. Your frog is drawn to the music, but notices strange ripples that don't match the current. Something magical is definitely at work here.",
                      choices: [
                        { id: 1, text: "Dive into the deepest part", risk: "high" },
                        { id: 2, text: "Wade in slowly and investigate", risk: "medium" },
                        { id: 3, text: "Drink from the edge carefully", risk: "low" }
                      ]
                    },
                    {
                      id: SecureRandom.uuid,
                      title: "The Ancient Lily Pad",
                      description: "An enormous lily pad floats in the center of a misty pond. It's covered in strange symbols that glow faintly, and there's a small treasure chest sitting in the middle. The pad seems stable, but the water around it is unnaturally dark.",
                      choices: [
                        { id: 1, text: "Leap directly to the treasure", risk: "high" },
                        { id: 2, text: "Hop to the edge and examine the symbols", risk: "medium" },
                        { id: 3, text: "Circle the pond looking for clues", risk: "low" }
                      ]
                    },
                    {
                      id: SecureRandom.uuid,
                      title: "The Firefly Parliament",
                      description: "Hundreds of fireflies hover in a perfect circle, pulsing in synchronized patterns. Your frog realizes they're communicating in some kind of light language. In the center of their formation floats a small, glowing orb.",
                      choices: [
                        { id: 1, text: "Rush into the center for the orb", risk: "high" },
                        { id: 2, text: "Try to mimic their light patterns", risk: "medium" },
                        { id: 3, text: "Watch and learn their language", risk: "low" }
                      ]
                    },
                    {
                      id: SecureRandom.uuid,
                      title: "The Upside-Down Tree",
                      description: "A massive tree grows upside-down from the sky, its roots dangling in the air and leaves buried in the ground. Strange fruits hang from the underground branches, glowing with inner light. The whole area defies gravity.",
                      choices: [
                        { id: 1, text: "Eat one of the glowing fruits", risk: "high" },
                        { id: 2, text: "Climb the hanging roots", risk: "medium" },
                        { id: 3, text: "Study the reversed ecosystem", risk: "low" }
                      ]
                    }
                  ]
                  
                      scenario = scenarios.sample
                      
                      { 
                        status: "success", 
                        scenario: scenario
                      }.to_json
                    end
                  rescue => e
                    puts "Adventure generation error: #{e.message}"
                    status 500
                    { status: "error", message: "Failed to generate adventure" }.to_json
                  end
                end
                
                # Make an adventure choice
                post "/choice" do
                  content_type :json
                  
                  begin
                    choice_params = JSON.parse(request.body.read)
                    choice = choice_params["choice"] || {}
                    scenario_id = choice_params["scenario_id"]
                    frog_stats = choice_params["frog_stats"] || {}
                    
                    # Use LLM to generate contextual outcome
                    llm_client = Frog::Adventure::Web::LLMClient.new
                    outcome = llm_client.process_adventure_choice(
                      scenario_id: scenario_id,
                      choice: choice,
                      frog_stats: frog_stats
                    )
                    
                    if outcome
                      # Convert OpenStruct to hash
                      outcome_data = {
                        message: outcome.message,
                        energy_change: outcome.energy_change,
                        happiness_change: outcome.happiness_change
                      }
                      outcome_data[:item] = outcome.item if outcome.respond_to?(:item) && outcome.item
                      
                      { 
                        status: "success", 
                        outcome: outcome_data
                      }.to_json
                    else
                      # Fallback to simple outcome if LLM fails
                      risk = choice["risk"] || "medium"
                      fallback_outcomes = {
                        high: { message: "Your bold action has consequences!", energy_change: -10, happiness_change: 5 },
                        medium: { message: "A balanced choice yields balanced results.", energy_change: 0, happiness_change: 10 },
                        low: { message: "Safe and sound, but nothing gained.", energy_change: 5, happiness_change: 5 }
                      }
                      
                      outcome = fallback_outcomes[risk.to_sym] || fallback_outcomes[:medium]
                      
                      { 
                        status: "success", 
                        outcome: outcome,
                        warning: "Using fallback outcome due to LLM error"
                      }.to_json
                    end
                  rescue => e
                    puts "Choice processing error: #{e.message}"
                    status 500
                    { status: "error", message: "Failed to process choice" }.to_json
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
                version: "0.1.0",
                environment: "development",
                timestamp: Time.now.iso8601
              }.to_json
            end
            
            # Simple test endpoint
            get "/test" do
              content_type :json
              { status: "test working", routes: "loaded" }.to_json
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