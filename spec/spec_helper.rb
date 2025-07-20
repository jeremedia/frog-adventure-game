# frozen_string_literal: true

require 'bundler/setup'
require 'rspec'

# Configure SimpleCov for code coverage
require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_filter '/vendor/'
  add_group 'Models', 'lib/frog/adventure/web/models'
  add_group 'Web App', 'lib/frog/adventure/web/app.rb'
  add_group 'Game Engine', 'lib/frog/adventure/web/game_engine.rb'
  add_group 'LLM Client', 'lib/frog/adventure/web/llm_client.rb'
  add_group 'Adventure Log', 'lib/frog/adventure/web/adventure_log.rb'
end

# Add the lib directory to the load path
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

# Require our gem
require 'frog/adventure/web'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end