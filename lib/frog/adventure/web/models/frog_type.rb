# frozen_string_literal: true

module Frog
  module Adventure
    module Web
      module Models
        # Enum-like module for frog types
        module FrogType
          TREE_FROG = "Tree Frog"
          POISON_DART_FROG = "Poison Dart Frog"
          BULLFROG = "Bullfrog"
          GLASS_FROG = "Glass Frog"
          ROCKET_FROG = "Rocket Frog"
          RAIN_FROG = "Rain Frog"
          CUSTOM = "Custom"

          ALL = [
            TREE_FROG,
            POISON_DART_FROG,
            BULLFROG,
            GLASS_FROG,
            ROCKET_FROG,
            RAIN_FROG,
            CUSTOM
          ].freeze

          def self.valid?(type)
            ALL.include?(type)
          end

          def self.random
            ALL.sample
          end
        end
      end
    end
  end
end