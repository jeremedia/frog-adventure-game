# frozen_string_literal: true

require_relative "web/version"
require_relative "web/app"
require_relative "web/game_engine"
require_relative "web/llm_client"

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
