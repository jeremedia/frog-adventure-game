# frozen_string_literal: true

require "bundler/setup"
require "frog/adventure/web"

# Run the Sinatra application
run Frog::Adventure::Web.app