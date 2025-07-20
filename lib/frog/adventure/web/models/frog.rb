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
                        :personality, :backstory

          DEFAULT_ENERGY = 100
          DEFAULT_HAPPINESS = 50

          def initialize(name:, frog_type:, ability:, description:, 
                         energy: DEFAULT_ENERGY, happiness: DEFAULT_HAPPINESS, 
                         items: nil, species: "", personality: "", backstory: "")
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
              backstory: @backstory
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
              backstory: data[:backstory] || ""
            )
          end
        end
      end
    end
  end
end