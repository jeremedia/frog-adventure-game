# frozen_string_literal: true

require_relative "lib/frog/adventure/web/version"

Gem::Specification.new do |spec|
  spec.name = "frog-adventure-web"
  spec.version = Frog::Adventure::Web::VERSION
  spec.authors = ["Jeremy Roush"]
  spec.email = ["j@zinod.com"]

  spec.summary = "A Ruby web game featuring AI-powered frog adventures"
  spec.description = "Frog Adventure Web is a browser-based adventure game where players team up with AI-generated frogs for infinite procedural adventures. Built with Sinatra and rubyllm for multi-provider LLM support."
  spec.homepage = "https://github.com/jeremedia/frog-adventure-game"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jeremedia/frog-adventure-game"
  spec.metadata["changelog_uri"] = "https://github.com/jeremedia/frog-adventure-game/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "sinatra", "~> 4.0"
  spec.add_dependency "sinatra-contrib", "~> 4.0"
  spec.add_dependency "rackup", "~> 2.1"
  spec.add_dependency "puma", "~> 6.4"
  spec.add_dependency "ruby_llm", "~> 1.3"
  spec.add_dependency "redis", "~> 5.0"
  spec.add_dependency "json", "~> 2.7"
  spec.add_dependency "dotenv", "~> 3.1"
  spec.add_dependency "rack-cors", "~> 2.0"
  spec.add_dependency "rack-request-id", "~> 0.0.4"

  # Development dependencies
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rack-test", "~> 2.1"
  spec.add_development_dependency "rubocop", "~> 1.65"
  spec.add_development_dependency "simplecov", "~> 0.22"
  spec.add_development_dependency "yard", "~> 0.9"
end
