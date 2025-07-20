# frozen_string_literal: true

module Frog
  module Adventure
    module Web
      module Models
        # Models module for game entities
      end
    end
  end
end

require_relative "models/frog_type"
require_relative "models/frog_personality"
require_relative "models/frog"
require_relative "models/generated_frog"
require_relative "models/game_event"
require_relative "models/events/choice_event"
require_relative "models/events/action_event"
require_relative "models/events/emotional_event"
require_relative "models/events/cinematic_event"