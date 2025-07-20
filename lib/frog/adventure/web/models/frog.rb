# frozen_string_literal: true

require 'json'

module Frog
  module Adventure
    module Web
      module Models
        # Represents a frog character in the game
        class Frog
          attr_accessor :name, :frog_type, :ability, :description, 
                        :energy, :happiness, :items, :species, 
                        :personality, :backstory, :stats, :traits, :ability_cooldown

          DEFAULT_ENERGY = 100
          DEFAULT_HAPPINESS = 50
          DEFAULT_ABILITY_COOLDOWN = 0

          def initialize(name:, frog_type:, ability:, description:, 
                         energy: DEFAULT_ENERGY, happiness: DEFAULT_HAPPINESS, 
                         items: nil, species: "", personality: "", backstory: "",
                         stats: nil, traits: nil, ability_cooldown: DEFAULT_ABILITY_COOLDOWN)
            @name = name
            @frog_type = frog_type
            @ability = ability
            @description = description
            @energy = energy
            @happiness = happiness
            @items = items || []
            @species = species
            @personality = personality
            @backstory = backstory
            @stats = stats || generate_stats_for_type(frog_type)
            @traits = traits || generate_personality_traits
            @ability_cooldown = ability_cooldown

            validate!
          end

          def validate!
            raise ArgumentError, "Name cannot be empty" if name.nil? || name.empty?
            raise ArgumentError, "Invalid frog type: #{frog_type}" unless FrogType.valid?(frog_type)
            raise ArgumentError, "Ability cannot be empty" if ability.nil? || ability.empty?
            raise ArgumentError, "Description cannot be empty" if description.nil? || description.empty?
            raise ArgumentError, "Energy must be between 0 and 100" unless (0..100).include?(energy)
            raise ArgumentError, "Happiness must be between 0 and 100" unless (0..100).include?(happiness)
            raise ArgumentError, "Items must be an array" unless items.is_a?(Array)
            raise ArgumentError, "Stats must be a hash" unless stats.is_a?(Hash)
            raise ArgumentError, "Traits must be an array" unless traits.is_a?(Array)
            raise ArgumentError, "Ability cooldown must be non-negative" unless ability_cooldown >= 0
            validate_stats!
          end

          def custom?
            frog_type == FrogType::CUSTOM
          end

          def display_type
            custom? ? species : frog_type
          end

          def add_item(item)
            @items << item unless @items.include?(item)
          end

          def remove_item(item)
            @items.delete(item)
          end

          def adjust_energy(amount)
            @energy = [[@energy + amount, 0].max, 100].min
          end

          def adjust_happiness(amount)
            @happiness = [[@happiness + amount, 0].max, 100].min
          end

          def tired?
            @energy < 20
          end

          def happy?
            @happiness > 70
          end

          def sad?
            @happiness < 30
          end

          # Stats and abilities system
          def ability_power
            base_power = 10 # Base ability power
            magic_bonus = @stats[:magic] / 20.0
            base_power * (1 + magic_bonus)
          end

          def can_use_ability?
            @ability_cooldown == 0
          end

          def use_ability!
            return false unless can_use_ability?
            @ability_cooldown = 3 # Default 3-turn cooldown
            true
          end

          def reduce_cooldown!
            @ability_cooldown = [@ability_cooldown - 1, 0].max
          end

          def total_stats
            @stats.values.sum
          end

          def to_h
            {
              name: @name,
              type: @frog_type,
              ability: @ability,
              description: @description,
              energy: @energy,
              happiness: @happiness,
              items: @items,
              species: @species,
              personality: @personality,
              backstory: @backstory,
              stats: @stats,
              traits: @traits,
              ability_cooldown: @ability_cooldown
            }
          end

          def to_json(*args)
            to_h.to_json(*args)
          end

          def self.from_json(json_string)
            data = JSON.parse(json_string, symbolize_names: true)
            from_hash(data)
          end

          def self.from_hash(data)
            new(
              name: data[:name],
              frog_type: data[:type] || data[:frog_type],
              ability: data[:ability],
              description: data[:description],
              energy: data[:energy] || DEFAULT_ENERGY,
              happiness: data[:happiness] || DEFAULT_HAPPINESS,
              items: data[:items] || [],
              species: data[:species] || "",
              personality: data[:personality] || "",
              backstory: data[:backstory] || "",
              stats: data[:stats],
              traits: data[:traits],
              ability_cooldown: data[:ability_cooldown] || DEFAULT_ABILITY_COOLDOWN
            )
          end

          private

          def generate_stats_for_type(type)
            base_stats = base_stats_for_type(type)
            {
              strength: roll_stat(base_stats[:strength]),
              agility: roll_stat(base_stats[:agility]),
              intelligence: roll_stat(base_stats[:intelligence]),
              magic: roll_stat(base_stats[:magic]),
              luck: roll_stat(base_stats[:luck])
            }
          end

          def base_stats_for_type(type)
            case type
            when FrogType::TREE_FROG
              { strength: 8, agility: 15, intelligence: 12, magic: 10, luck: 10 }
            when FrogType::POISON_DART_FROG
              { strength: 6, agility: 18, intelligence: 14, magic: 8, luck: 9 }
            when FrogType::BULLFROG
              { strength: 18, agility: 6, intelligence: 8, magic: 12, luck: 11 }
            when FrogType::GLASS_FROG
              { strength: 5, agility: 12, intelligence: 16, magic: 15, luck: 7 }
            when FrogType::ROCKET_FROG
              { strength: 12, agility: 20, intelligence: 10, magic: 14, luck: 9 }
            when FrogType::RAIN_FROG
              { strength: 10, agility: 8, intelligence: 18, magic: 16, luck: 13 }
            when FrogType::CUSTOM
              { strength: 11, agility: 11, intelligence: 11, magic: 11, luck: 11 }
            else
              { strength: 10, agility: 10, intelligence: 10, magic: 10, luck: 10 }
            end
          end

          def roll_stat(base_value)
            # Add random variation (-3 to +5) but keep within 5-20 range
            variation = rand(-3..5)
            result = base_value + variation
            [[result, 5].max, 20].min
          end

          def generate_personality_traits
            all_traits = [
              "Brave", "Cautious", "Friendly", "Grumpy", "Curious", "Lazy",
              "Energetic", "Calm", "Mischievous", "Loyal", "Independent", "Wise",
              "Playful", "Serious", "Optimistic", "Pessimistic", "Patient", "Impulsive"
            ]
            
            # Generate 2-3 traits, ensuring no contradictions
            num_traits = rand(2..3)
            contradictory_pairs = [
              ["Brave", "Cautious"], ["Friendly", "Grumpy"], ["Energetic", "Lazy"],
              ["Optimistic", "Pessimistic"], ["Patient", "Impulsive"]
            ]
            
            selected_traits = []
            available_traits = all_traits.dup
            
            num_traits.times do
              break if available_traits.empty?
              
              trait = available_traits.sample
              selected_traits << trait
              available_traits.delete(trait)
              
              # Remove contradictory traits
              contradictory_pairs.each do |pair|
                if pair.include?(trait)
                  other_trait = pair.find { |t| t != trait }
                  available_traits.delete(other_trait)
                end
              end
            end
            
            selected_traits
          end

          def validate_stats!
            required_stats = [:strength, :agility, :intelligence, :magic, :luck]
            required_stats.each do |stat|
              unless @stats.key?(stat)
                raise ArgumentError, "Missing required stat: #{stat}"
              end
              
              unless (5..20).include?(@stats[stat])
                raise ArgumentError, "Stat #{stat} must be between 5 and 20, got #{@stats[stat]}"
              end
            end
            
            # Ensure total stats aren't too high (prevent super-frogs)
            if total_stats > 85
              raise ArgumentError, "Total stats too high: #{total_stats} (max 85)"
            end
          end
        end
      end
    end
  end
end