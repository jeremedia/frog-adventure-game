# frozen_string_literal: true

require "ruby_llm"

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
            # Fallback to procedural generation if LLM fails
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

        private

        def configure_llm
          # Configure rubyllm based on environment
          # Support multiple providers (OpenAI, Anthropic, Ollama, etc.)
          RubyLLM.configure do |config|
            # Provider configuration will be added based on ENV
          end
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
          # For now, return a mock response until we have actual LLM integration
          # This will be replaced with actual rubyllm calls
          {
            "name" => "Sparky",
            "ability" => "Lightning Leap",
            "description" => "A vibrant green tree frog with electric blue toe pads that sparkle with energy",
            "species" => "Electrophorus Hopicus",
            "backstory" => "Once struck by magical lightning while climbing the Great Oak, gained incredible speed and electrical powers"
          }
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
      end
    end
  end
end