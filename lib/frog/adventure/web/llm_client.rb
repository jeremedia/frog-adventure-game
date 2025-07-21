# frozen_string_literal: true

require "ruby_llm"
require "ostruct"
require "securerandom"

module Frog
  module Adventure
    module Web
      # Handles all LLM interactions for dynamic content generation
      class LLMClient
        def initialize
          configure_llm
        end

        # Generate a unique frog with personality
        def generate_frog(frog_type: nil)
          frog_type ||= Frog::Adventure::Web::Models::FrogType.random
          
          # Create base frog to get generated stats and traits
          base_frog = Frog::Adventure::Web::Models::Frog.new(
            name: "Temporary",
            frog_type: frog_type,
            ability: "Temp",
            description: "Temp"
          )
          
          prompt = build_frog_generation_prompt(frog_type, base_frog.stats, base_frog.traits)
          
          begin
            response = query_llm(prompt)
            return parse_frog_response(response, frog_type, base_frog.stats, base_frog.traits)
          rescue => e
            puts "LLM frog generation failed: #{e.message}"
            return generate_fallback_frog(frog_type, base_frog.stats, base_frog.traits)
          end
        end

        # Generate an adventure scenario
        def generate_adventure(context)
          # TODO: Implement LLM-based adventure generation
          # Will use context from previous adventures
          nil
        end

        # Generate contextual dialogue
        def generate_dialogue(frog_personality, situation)
          # TODO: Implement personality-based dialogue
          nil
        end

        # Make adventure methods public since they're used in routes
        def generate_adventure_scenario(frog_stats: {})
          prompt = build_adventure_scenario_prompt(frog_stats)
          
          begin
            llm_response = query_llm(prompt)
            scenario_data = parse_adventure_scenario(llm_response)
            scenario_data[:id] = SecureRandom.uuid
            return OpenStruct.new(scenario_data)
          rescue => e
            puts "LLM adventure generation failed: #{e.message}"
            return generate_fallback_scenario
          end
        end

        def process_adventure_choice(scenario_id:, choice:, frog_stats: {})
          prompt = build_choice_outcome_prompt(choice, frog_stats)
          
          begin
            llm_response = query_llm(prompt)
            outcome_data = parse_choice_outcome(llm_response)
            outcome_data[:scenario_id] = scenario_id
            outcome_data[:choice_made] = choice
            return OpenStruct.new(outcome_data)
          rescue => e
            puts "LLM choice processing failed: #{e.message}"
            return generate_fallback_outcome(choice, scenario_id)
          end
        end

        private

        def configure_llm
          # Configure ruby_llm to use Ollama for local LLM generation
          # RubyLLM uses environment variables for configuration
          ENV['OLLAMA_API_BASE'] = "http://localhost:11434"
          ENV['LLM_PROVIDER'] = 'ollama'
          ENV['OLLAMA_MODEL'] = 'gemma3n:e4b'
        end

        def build_frog_generation_prompt(frog_type, stats, traits)
          <<~PROMPT
            Generate a unique companion frog for a roguelike adventure game.

            **Frog Type**: #{frog_type}
            **Stats**: Strength #{stats[:strength]}, Agility #{stats[:agility]}, Intelligence #{stats[:intelligence]}, Magic #{stats[:magic]}, Luck #{stats[:luck]}
            **Personality Traits**: #{traits.join(", ")}

            Create a frog that matches these stats and traits. The stats should influence their backstory and abilities.

            Respond in this exact JSON format:
            {
              "name": "Unique frog name",
              "ability": "Special ability description (should reflect high stats)",
              "description": "Physical description and demeanor matching traits",
              "species": "Scientific or fantasy species name",
              "backstory": "Brief origin story explaining stats and personality"
            }

            Examples of stat-appropriate abilities:
            - High Strength: "Earthquake Stomp", "Boulder Toss"
            - High Agility: "Lightning Dash", "Wall Running"
            - High Intelligence: "Ancient Knowledge", "Puzzle Master"
            - High Magic: "Elemental Control", "Mystical Healing"
            - High Luck: "Fortune's Favor", "Serendipity"

            Make the name, ability, and description cohesive and memorable.
          PROMPT
        end

        def query_llm(prompt)
          # Use RubyLLM to query Ollama
          begin
            # puts "DEBUG: Querying LLM with prompt length: #{prompt.length}"
            
            # Direct call to Ollama API since RubyLLM might not support it properly
            require 'net/http'
            require 'json'
            
            uri = URI("http://localhost:11434/api/generate")
            request = Net::HTTP::Post.new(uri)
            request['Content-Type'] = 'application/json'
            request.body = {
              model: 'gemma3n:e4b',
              prompt: prompt,
              stream: false,
              temperature: 0.8
            }.to_json
            
            # puts "DEBUG: Sending request to Ollama..."
            response = Net::HTTP.start(uri.hostname, uri.port) do |http|
              http.read_timeout = 30
              http.request(request)
            end
            
            # puts "DEBUG: Got response from Ollama: #{response.code}"
            
            if response.code == '200'
              result = JSON.parse(response.body)
              generated_text = result['response'].strip
              # puts "DEBUG: Generated text (#{generated_text.length} chars)"
              return generated_text
            else
              raise "Ollama API error: #{response.code} - #{response.body}"
            end
          rescue => e
            # Fallback to mock data if LLM fails
            puts "LLM call failed: #{e.class} - #{e.message}"
            puts "Backtrace: #{e.backtrace.first(3).join("\n")}"
            puts "Using fallback data..."
            return generate_mock_response(prompt)
          end
        end

        def generate_mock_response(prompt)
          # Fallback mock responses when LLM is unavailable
          if prompt.include?("adventure scenario")
            return generate_mock_scenario
          elsif prompt.include?("companion frog")
            return generate_mock_frog
          else
            return "{\"error\": \"Mock response not implemented for this prompt type\"}"
          end
        end

        def generate_mock_frog
          mock_frogs = [
            {
              "name" => "Sparky",
              "ability" => "Lightning Leap",
              "description" => "A vibrant green tree frog with electric blue toe pads that sparkle with energy",
              "species" => "Electrophorus Hopicus",
              "backstory" => "Once struck by magical lightning while climbing the Great Oak, gained incredible speed and electrical powers"
            },
            {
              "name" => "Bubbles",
              "ability" => "Bubble Shield",
              "description" => "A translucent glass frog with iridescent skin that shimmers like soap bubbles",
              "species" => "Translucida Magnificus",
              "backstory" => "Born in a magical spring, this frog can create protective bubbles and see through illusions"
            },
            {
              "name" => "Rocky",
              "ability" => "Stone Skin",
              "description" => "A sturdy brown frog with rock-like bumps covering its tough hide",
              "species" => "Petra Fortis",
              "backstory" => "Raised among ancient stone guardians, developed unbreakable skin and earth magic"
            },
            {
              "name" => "Whisper",
              "ability" => "Shadow Step",
              "description" => "A sleek black frog with silver markings that seem to shift in moonlight",
              "species" => "Umbra Silentis",
              "backstory" => "A master of stealth who learned the ancient art of shadow travel from the night spirits"
            },
            {
              "name" => "Prism",
              "ability" => "Rainbow Beam",
              "description" => "A colorful frog whose skin changes hues like a living rainbow",
              "species" => "Chromata Spectrus",
              "backstory" => "Blessed by a fallen star, this frog can bend light and create dazzling displays"
            },
            {
              "name" => "Sage",
              "ability" => "Ancient Wisdom",
              "description" => "An elderly-looking frog with wise amber eyes and mystical runes on its back",
              "species" => "Sapientia Eternus",
              "backstory" => "The oldest frog in the realm, keeper of forgotten knowledge and magical secrets"
            }
          ]
          
          mock_frogs.sample
        end

        def parse_frog_response(response, frog_type, stats, traits)
          # In a real implementation, this would parse JSON from LLM
          # For now, work with the mock response
          if response.is_a?(Hash)
            data = response
          else
            # Try to parse JSON response
            begin
              data = JSON.parse(response)
            rescue JSON::ParserError
              return generate_fallback_frog(frog_type, stats, traits)
            end
          end

          Frog::Adventure::Web::Models::Frog.new(
            name: data["name"] || "Unnamed Frog",
            frog_type: frog_type,
            ability: data["ability"] || "Hop",
            description: data["description"] || "A mysterious frog",
            species: data["species"] || "",
            backstory: data["backstory"] || "",
            stats: stats,
            traits: traits
          )
        end

        def generate_fallback_frog(frog_type, stats, traits)
          # Procedural generation based on highest stat
          highest_stat = stats.max_by { |_, value| value }
          stat_name, stat_value = highest_stat

          ability_map = {
            strength: ["Power Slam", "Rock Crush", "Mighty Leap"],
            agility: ["Quick Dash", "Acrobatic Dodge", "Speed Burst"],
            intelligence: ["Clever Solution", "Memory Palace", "Strategic Mind"],
            magic: ["Mystic Blast", "Healing Touch", "Elemental Control"],
            luck: ["Lucky Break", "Fortune's Smile", "Serendipity"]
          }

          name_prefixes = {
            strength: ["Tank", "Brick", "Boulder"],
            agility: ["Swift", "Dash", "Nimble"],
            intelligence: ["Sage", "Scholar", "Wise"],
            magic: ["Mystic", "Spark", "Enchant"],
            luck: ["Lucky", "Chance", "Fortunate"]
          }

          prefix = name_prefixes[stat_name].sample
          name = "#{prefix}#{frog_type.split.first}"

          Frog::Adventure::Web::Models::Frog.new(
            name: name,
            frog_type: frog_type,
            ability: ability_map[stat_name].sample,
            description: "A #{traits.map(&:downcase).join(' and ')} #{frog_type.downcase} with exceptional #{stat_name}",
            species: "Proceduralus #{stat_name}us",
            backstory: "Born with natural #{stat_name} abilities, this frog excels in #{stat_name}-based challenges",
            stats: stats,
            traits: traits
          )
        end


        def build_adventure_scenario_prompt(frog_stats)
          strength = frog_stats[:strength] || 10
          agility = frog_stats[:agility] || 10
          intelligence = frog_stats[:intelligence] || 10
          magic = frog_stats[:magic] || 10
          luck = frog_stats[:luck] || 10
          
          # Randomly select diverse settings and themes for variety
          settings = [
            "mystical crystal caverns deep underground",
            "floating sky islands connected by rainbow bridges", 
            "abandoned clockwork city with mechanical guardians",
            "underwater coral palace beneath the lake",
            "volcanic fire realm with lava flows and ember sprites",
            "frozen ice kingdom with aurora magic",
            "desert oasis surrounded by sand wyrms",
            "ancient library tower filled with living books",
            "mushroom forest with giant fungi and spore clouds",
            "starlit meadow where dreams become reality",
            "windswept mountain peaks with storm giants",
            "enchanted marketplace between dimensions"
          ]
          
          themes = [
            "mysterious artifact discovery",
            "rival adventurer encounter", 
            "natural disaster or magical phenomenon",
            "ancient puzzle or riddle challenge",
            "trapped creature needing rescue",
            "guardian spirit testing worthiness",
            "time distortion or dimensional rift",
            "cursed treasure with moral dilemma",
            "lost civilization remnants",
            "shapeshifting trickster encounter",
            "elemental imbalance threatening the realm",
            "memory-stealing enchantment"
          ]
          
          setting = settings.sample
          theme = themes.sample
          
          <<~PROMPT
            Create a completely unique adventure scenario for a frog companion exploring diverse magical realms.
            
            **Setting**: #{setting}
            **Theme**: #{theme}
            **Frog Stats**: Strength #{strength}, Agility #{agility}, Intelligence #{intelligence}, Magic #{magic}, Luck #{luck}
            
            Generate an exciting scenario that combines the setting and theme in an unexpected way. The scenario should:
            - Use the specific setting and theme provided above (NOT a generic forest)
            - Be appropriate for the frog's stat levels (higher stats = more dangerous/complex scenarios)
            - Include exactly 3 meaningful choices with different risk levels
            - Have vivid descriptions that create atmosphere unique to this setting
            - Offer opportunities for different approaches based on different stats
            - Be completely different from "Whispering Glade" or any forest scenario
            
            Respond ONLY with valid JSON in this exact format:
            {
              "title": "Short descriptive title incorporating the setting",
              "description": "Detailed scenario description that sets the scene in the specified setting and incorporates the theme",
              "choices": [
                {"id": 1, "text": "Action-oriented choice description", "risk": "high"},
                {"id": 2, "text": "Cautious/clever choice description", "risk": "medium"},
                {"id": 3, "text": "Safe/retreat choice description", "risk": "low"}
              ]
            }

            IMPORTANT: Make this scenario completely unique and avoid any forest, glade, or woodland themes!
          PROMPT
        end

        def parse_adventure_scenario(llm_response)
          # Try to extract JSON from LLM response
          json_match = llm_response.match(/\{.*\}/m)
          if json_match
            JSON.parse(json_match[0], symbolize_names: true)
          else
            raise "No valid JSON found in LLM response"
          end
        end

        def generate_fallback_scenario
          fallback_scenarios = [
            {
              id: SecureRandom.uuid,
              title: "The Mysterious Lily Pad",
              description: "You discover a glowing lily pad in the middle of the pond. It seems magical but potentially dangerous.",
              choices: [
                { id: 1, text: "Jump onto the lily pad", risk: "medium" },
                { id: 2, text: "Investigate from a safe distance", risk: "low" },
                { id: 3, text: "Swim away quickly", risk: "none" }
              ]
            },
            {
              id: SecureRandom.uuid,
              title: "The Singing Cricket",
              description: "A cricket approaches and begins singing a haunting melody. Other frogs seem mesmerized by it.",
              choices: [
                { id: 1, text: "Listen to the full song", risk: :high },
                { id: 2, text: "Sing along with the cricket", risk: :medium },
                { id: 3, text: "Cover your ears and hop away", risk: :low }
              ]
            },
            {
              id: SecureRandom.uuid,
              title: "The Golden Fly",
              description: "A shimmering golden fly buzzes just out of reach. It looks delicious but seems too good to be true.",
              choices: [
                { id: 1, text: "Leap high to catch it", risk: :medium },
                { id: 2, text: "Wait for it to come closer", risk: :low },
                { id: 3, text: "Look for other food instead", risk: :none }
              ]
            }
          ]

          scenario = fallback_scenarios.sample
          
          # Create a simple scenario struct
          OpenStruct.new(scenario)
        end

        def build_choice_outcome_prompt(choice, frog_stats)
          strength = frog_stats[:strength] || 10
          agility = frog_stats[:agility] || 10
          intelligence = frog_stats[:intelligence] || 10
          magic = frog_stats[:magic] || 10
          luck = frog_stats[:luck] || 10
          risk = choice["risk"] || "medium"
          
          <<~PROMPT
            Process the outcome of an adventure choice for a frog companion.
            
            **Choice Made**: "#{choice["text"]}"
            **Risk Level**: #{risk}
            **Frog Stats**: Strength #{strength}, Agility #{agility}, Intelligence #{intelligence}, Magic #{magic}, Luck #{luck}
            
            Generate a narrative outcome that:
            - Reflects the risk level (high risk = more dramatic results, both good and bad)
            - Considers the frog's stats (higher relevant stats = better success chance)
            - Provides meaningful consequences (energy/happiness changes, possible items)
            - Tells a compelling micro-story of what happened
            
            Respond ONLY with valid JSON:
            {
              "message": "Detailed description of what happened and the result",
              "energy_change": -15 to +15 (integer, negative loses energy),
              "happiness_change": -15 to +20 (integer, negative loses happiness),
              "item": "Item name or null" (only sometimes, like "Ancient Key" or "Magic Berry")
            }

            Guidelines for stat influence:
            - High Strength: Better physical challenges, fighting, lifting
            - High Agility: Better dodging, climbing, quick reactions  
            - High Intelligence: Better puzzles, social situations, planning
            - High Magic: Better magical interactions, spells, enchanted items
            - High Luck: Better random outcomes, finding things, avoiding traps

            Risk level effects:
            - Low: Mostly positive outcomes, small changes
            - Medium: Mixed outcomes, moderate changes
            - High: Dramatic outcomes (very good or very bad), large changes
          PROMPT
        end

        def parse_choice_outcome(llm_response)
          json_match = llm_response.match(/\{.*\}/m)
          if json_match
            JSON.parse(json_match[0], symbolize_names: true)
          else
            raise "No valid JSON found in LLM response"
          end
        end

        def generate_fallback_outcome(choice, scenario_id)
          outcomes = {
            success: [
              { message: "Success! You gained valuable experience.", energy_change: 5, happiness_change: 15 },
              { message: "Well done! You discovered a hidden treasure.", energy_change: 0, happiness_change: 20, item: "Shiny Pebble" },
              { message: "Excellent choice! You feel more confident.", energy_change: 10, happiness_change: 10 }
            ],
            partial: [
              { message: "You succeeded partially but learned something new.", energy_change: -5, happiness_change: 10 },
              { message: "It worked out okay, though not perfectly.", energy_change: 0, happiness_change: 5 }
            ],
            failure: [
              { message: "That didn't go as planned, but you're wiser now.", energy_change: -10, happiness_change: -5 },
              { message: "Oops! Better luck next time.", energy_change: -15, happiness_change: 0 },
              { message: "You learned what not to do next time.", energy_change: -5, happiness_change: -10 }
            ]
          }

          risk_level = choice["risk"] || "medium"
          outcome_type = case risk_level.to_s
          when "none", "low"
            [:success, :partial].sample
          when "medium"
            [:success, :partial, :failure].sample
          when "high"
            [:partial, :failure].sample
          else
            :partial
          end

          result = outcomes[outcome_type].sample
          result[:scenario_id] = scenario_id
          result[:choice_made] = choice
          OpenStruct.new(result)
        end
      end
    end
  end
end