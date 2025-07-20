# CI/CD Configuration

This document describes the Continuous Integration and Continuous Deployment setup for the Frog Adventure Web project.

## GitHub Actions Workflows

### Test Workflow (`.github/workflows/test.yml`)

Runs on every push and pull request to ensure code quality:

- **Ruby Version Matrix**: Tests against Ruby 3.1, 3.2, and 3.3
- **RuboCop Linting**: Enforces Ruby code style guidelines
- **RSpec Tests**: Runs the full test suite
- **Gem Build Verification**: Ensures the gem can be built successfully

### Code Coverage Workflow (`.github/workflows/coverage.yml`)

Tracks test coverage on main branch:

- **SimpleCov Integration**: Generates coverage reports
- **Codecov Upload**: Sends reports to Codecov service
- **Coverage Groups**: Organized by component (Models, Web App, Game Engine, etc.)

### Gem Publishing Workflow (`.github/workflows/publish.yml`)

Manual workflow for releasing new versions:

- **Trigger**: Manual dispatch or GitHub release creation
- **RubyGems Publication**: Automatically publishes to rubygems.org
- **Security**: Uses `RUBYGEMS_API_KEY` secret

### Dependency Updates (`.github/dependabot.yml`)

Automated dependency management:

- **Bundler**: Weekly updates for Ruby gems
- **GitHub Actions**: Weekly updates for workflow actions
- **Auto-PR Creation**: Opens PRs for dependency updates
- **Review Assignment**: Automatically assigns @jeremedia

## Setup Instructions

### Required Secrets

1. **CODECOV_TOKEN**: Get from [codecov.io](https://codecov.io)
2. **RUBYGEMS_API_KEY**: Get from [rubygems.org](https://rubygems.org) profile

Add these in GitHub repository settings under Settings → Secrets and variables → Actions.

### Running Locally

```bash
# Run tests with coverage
bundle exec rspec

# Run linter
bundle exec rubocop

# Build gem
gem build frog-adventure-web.gemspec
```

## Coverage Configuration

SimpleCov is configured in `spec/spec_helper.rb` with:

- Filters for spec and vendor directories
- Groups for logical code organization
- HTML and JSON formatters for local and CI use

## Workflow Badges

Add these to your README.md:

```markdown
[![Tests](https://github.com/jeremedia/frog-adventure-game/actions/workflows/test.yml/badge.svg)](https://github.com/jeremedia/frog-adventure-game/actions/workflows/test.yml)
[![Code Coverage](https://codecov.io/gh/jeremedia/frog-adventure-game/branch/main/graph/badge.svg)](https://codecov.io/gh/jeremedia/frog-adventure-game)
```