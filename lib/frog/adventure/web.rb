# frozen_string_literal: true

require_relative "web/version"
require_relative "web/config"
require_relative "web/models"
require_relative "web/routes"
require_relative "web/app"
require_relative "web/action_queue"
require_relative "web/game_event_system"
require_relative "web/game_engine"
require_relative "web/llm_client"
require_relative "web/middleware"
require_relative "web/adventure_log"

module Frog
  module Adventure
    module Web
      class Error < StandardError; end
      
      # Main entry point for the gem
      def self.app
        App
      end
    end
  end
end
