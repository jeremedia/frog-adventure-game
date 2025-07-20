# frozen_string_literal: true

module Frog
  module Adventure
    module Web
      module Models
        # Enum-like module for frog personalities
        module FrogPersonality
          ADVENTUROUS = "Adventurous"
          WISE = "Wise"
          PLAYFUL = "Playful"
          MYSTERIOUS = "Mysterious"
          BRAVE = "Brave"
          CURIOUS = "Curious"
          GRUMPY = "Grumpy"
          CHEERFUL = "Cheerful"
          
          ALL = [
            ADVENTUROUS,
            WISE,
            PLAYFUL,
            MYSTERIOUS,
            BRAVE,
            CURIOUS,
            GRUMPY,
            CHEERFUL
          ].freeze
          
          def self.valid?(personality)
            ALL.include?(personality)
          end
          
          def self.random
            ALL.sample
          end
        end
      end
    end
  end
end