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
                  
                  # Simple working fallback frogs with varied stats
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
                    },
                    {
                      name: "Bubbles",
                      type: "Glass Frog",
                      ability: "Bubble Shield",
                      description: "A translucent glass frog with iridescent skin that shimmers like soap bubbles",
                      energy: 100,
                      happiness: 75,
                      stats: { strength: 6, agility: 12, intelligence: 16, magic: 17, luck: 9 },
                      traits: ["Wise", "Calm"],
                      species: "Translucida Magnificus", 
                      backstory: "Born in a magical spring, this frog can create protective bubbles and see through illusions"
                    },
                    {
                      name: "Rocky",
                      type: "Bullfrog",
                      ability: "Stone Skin",
                      description: "A sturdy brown frog with rock-like bumps covering its tough hide",
                      energy: 100,
                      happiness: 75,
                      stats: { strength: 19, agility: 7, intelligence: 8, magic: 11, luck: 12 },
                      traits: ["Patient", "Loyal"],
                      species: "Petra Fortis",
                      backstory: "Raised among ancient stone guardians, developed unbreakable skin and earth magic"
                    },
                    {
                      name: "Prism",
                      type: "Poison Dart Frog",
                      ability: "Rainbow Beam",
                      description: "A colorful frog whose skin changes hues like a living rainbow",
                      energy: 100,
                      happiness: 75,
                      stats: { strength: 7, agility: 16, intelligence: 14, magic: 18, luck: 8 },
                      traits: ["Curious", "Mischievous"],
                      species: "Chromata Spectrus",
                      backstory: "Blessed by a fallen star, this frog can bend light and create dazzling displays"
                    },
                    {
                      name: "Sage",
                      type: "Rain Frog",
                      ability: "Ancient Wisdom",
                      description: "An elderly-looking frog with wise amber eyes and mystical runes on its back",
                      energy: 100,
                      happiness: 75,
                      stats: { strength: 9, agility: 8, intelligence: 20, magic: 16, luck: 15 },
                      traits: ["Wise", "Patient"],
                      species: "Sapientia Eternus",
                      backstory: "The oldest frog in the realm, keeper of forgotten knowledge and magical secrets"
                    }
                  ]
                  
                  selected_frog = fallback_frogs.sample
                  
                  { 
                    status: "success", 
                    frog: selected_frog 
                  }.to_json
                end
              end
              
              # Adventure routes
              namespace "/adventure" do
                # Start a new adventure
                post "/start" do
                  content_type :json
                  
                  # Working adventure scenarios
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
                
                # Make an adventure choice
                post "/choice" do
                  content_type :json
                  
                  choice_params = JSON.parse(request.body.read)
                  choice = choice_params["choice"] || {}
                  risk = choice["risk"] || "medium"
                  
                  # Generate outcomes based on risk level
                  outcomes = {
                    high: [
                      { message: "Your bold action pays off spectacularly! You discover a hidden magical artifact!", energy_change: 10, happiness_change: 25, item: "Mystic Crystal" },
                      { message: "The risk was too great! Your frog gets caught in a magical trap but escapes with new wisdom.", energy_change: -15, happiness_change: 5 },
                      { message: "Amazing! Your frog unlocks a secret passage to a treasure chamber!", energy_change: 0, happiness_change: 30, item: "Golden Lily Pad" },
                      { message: "The magic backfires! Your frog is temporarily confused but gains magical resistance.", energy_change: -20, happiness_change: -5 }
                    ],
                    medium: [
                      { message: "A wise choice! Your careful approach reveals valuable secrets.", energy_change: 5, happiness_change: 15, item: "Ancient Map" },
                      { message: "Your frog learns something important about forest magic!", energy_change: 0, happiness_change: 20 },
                      { message: "Good thinking! You avoid danger and find a useful herb.", energy_change: 10, happiness_change: 10, item: "Healing Moss" },
                      { message: "Your patience is rewarded with new magical knowledge.", energy_change: -5, happiness_change: 15 }
                    ],
                    low: [
                      { message: "Safe and sound! Your cautious approach keeps everyone happy.", energy_change: 15, happiness_change: 10 },
                      { message: "Smart choice! Sometimes the best adventure is staying safe.", energy_change: 20, happiness_change: 5 },
                      { message: "Your frog appreciates the careful approach and feels well-rested.", energy_change: 25, happiness_change: 10 },
                      { message: "A peaceful resolution. Your frog gains confidence from the safe choice.", energy_change: 10, happiness_change: 20 }
                    ]
                  }
                  
                  risk_level = risk.to_sym
                  available_outcomes = outcomes[risk_level] || outcomes[:medium]
                  outcome = available_outcomes.sample
                  
                  { 
                    status: "success", 
                    outcome: outcome
                  }.to_json
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