# Frog::Adventure::Web

TODO: Delete this and the text below, and describe your gem

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/frog/adventure/web`. To experiment with that code, run `bin/console` for an interactive prompt.

## Installation

TODO: Replace `UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG` with your gem name right after releasing it to RubyGems.org. Please do not do it earlier due to security reasons. Alternatively, replace this section with instructions to install your gem from git if you don't plan to release to RubyGems.org.

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install UPDATE_WITH_YOUR_GEM_NAME_IMMEDIATELY_AFTER_RELEASE_TO_RUBYGEMS_ORG
```

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Docker Development Environment

This project includes Docker support for a consistent development environment.

#### Prerequisites
- Docker Desktop or Docker Engine installed
- Docker Compose (included with Docker Desktop)

#### Getting Started with Docker

1. **Build and start the containers:**
   ```bash
   docker-compose up --build
   ```

2. **Access the application:**
   - Web app: http://localhost:4567
   - Redis: localhost:6379

3. **Run commands in the container:**
   ```bash
   # Run tests
   docker-compose run web bundle exec rspec

   # Access Rails console
   docker-compose run web bin/console

   # Install new gems
   docker-compose run web bundle install
   ```

4. **Stop the containers:**
   ```bash
   docker-compose down
   ```

#### Docker Configuration Details

- **Ruby Version:** 3.2+ (slim image for smaller size)
- **Services:**
  - `web`: The main Ruby application
  - `redis`: Redis server for caching and session storage
- **Volumes:**
  - Application code is mounted for live reloading
  - Gem cache is persisted between container restarts
  - Redis data is persisted
- **Environment Variables:**
  - `REDIS_URL` is automatically configured

#### Troubleshooting Docker

- **Rebuild containers after Gemfile changes:**
  ```bash
  docker-compose build
  ```

- **Clean up all containers and volumes:**
  ```bash
  docker-compose down -v
  ```

- **View logs:**
  ```bash
  docker-compose logs -f [service_name]
  ```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/frog-adventure-web.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
