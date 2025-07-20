# Use official Ruby runtime as base image
FROM ruby:3.2-slim

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy gemspec and Gemfile first for better caching
COPY frog-adventure-web.gemspec Gemfile* ./
COPY lib/frog/adventure/web/version.rb lib/frog/adventure/web/

# Install gems
RUN bundle install

# Copy application code
COPY . .

# Expose port for Sinatra
EXPOSE 4567

# Run the application
CMD ["bundle", "exec", "rackup", "-o", "0.0.0.0", "-p", "4567"]