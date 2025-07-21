# Frog Adventure Web

A Ruby gem-based roguelike web application where frog companion stats dramatically change adventures, transforming gameplay into AI-generated interactive stories.

## 🎮 Game Concept

This is a roguelike where the stats and abilities of your companion frog dramatically change the adventure. Each adventure is dynamically generated using AI (Ollama LLM) based on your frog's unique characteristics. The game features:

- **Procedurally Generated Frogs**: Each companion has unique stats, abilities, and backstories
- **Dynamic Adventures**: AI-generated scenarios that adapt to your frog's capabilities
- **Infinite Variety**: 144+ unique adventure combinations across diverse magical realms
- **Interactive Choices**: Multiple approaches based on different stat combinations
- **Virtual Pet Mechanics**: Energy and happiness systems requiring player care

## 🌐 Live Demo

The game is deployed at: **https://frog.zice.app**

## 🛠 Architecture

### Technology Stack
- **Backend**: Ruby 3.4+ with Sinatra web framework
- **AI Integration**: Ollama LLM (gemma3n:e4b model) for dynamic content generation
- **Frontend**: Vanilla JavaScript with responsive CSS
- **Session Management**: Cookie-based sessions with Redis support
- **Security**: Rack::Protection middleware with configurable host authorization

### Key Components

#### Ruby Web Application (`lib/frog/adventure/web/`)
- **App** (`app.rb`): Main Sinatra application with route handling
- **GameEngine** (`game_engine.rb`): Core game logic and state management
- **LLMClient** (`llm_client.rb`): Multi-provider LLM integration with fallback systems
- **Routes** (`routes.rb`): RESTful API endpoints for game actions
- **Models** (`models.rb`): Data structures for frogs, adventures, and game state

#### Frontend (`public/`)
- **Interactive UI**: Real-time frog generation and adventure controls
- **Game Interface**: Status bars, choice buttons, and adventure log
- **Responsive Design**: Mobile-friendly layout with CSS animations
- **Loading States**: Visual feedback during LLM generation

#### Adventure Generation System
- **12 Unique Settings**: Crystal caverns, sky islands, clockwork cities, underwater palaces, volcanic realms, ice kingdoms, desert oases, library towers, mushroom forests, starlit meadows, mountain peaks, dimensional marketplaces
- **12 Varied Themes**: Artifact discovery, rival encounters, natural disasters, puzzles, rescues, spirit tests, time distortions, cursed treasures, lost civilizations, tricksters, elemental imbalances, memory enchantments
- **Random Combinations**: Each adventure combines one setting + one theme for infinite variety

## 🚀 Installation & Setup

### Prerequisites
- Ruby 3.4+ with bundler
- Ollama installed and running locally
- Optional: Redis for session persistence

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/jeremedia/frog-adventure-game.git
   cd frog-adventure-game
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Set up Ollama LLM:**
   ```bash
   # Install Ollama (if not already installed)
   curl -fsSL https://ollama.ai/install.sh | sh
   
   # Pull the required model
   ollama pull gemma3n:e4b
   
   # Start Ollama server
   ollama serve
   ```

4. **Run the development server:**
   ```bash
   # Foreground (blocking)
   bundle exec rackup -p 4567
   
   # Background (non-blocking)
   bundle exec rackup -p 4567 -D
   ```

5. **Access the application:**
   - Local: http://localhost:4567
   - Game UI: http://localhost:4567/game

### Production Deployment

1. **Configure for production:**
   ```bash
   # Set environment variables
   export RACK_ENV=production
   export SESSION_SECRET=your_secure_session_secret
   
   # Optional Redis configuration
   export REDIS_URL=redis://localhost:6379
   ```

2. **Start production server:**
   ```bash
   RACK_ENV=production bundle exec rackup -o 0.0.0.0 -p 4567
   ```

3. **External domain configuration** (for reverse proxy setups):
   ```ruby
   # The app automatically disables host protection in production
   # Configure your reverse proxy (Caddy, nginx, etc.) to forward to the app
   ```

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
   
   # Access console
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

## 🎯 Usage

### Basic Gameplay Flow

1. **Generate a Frog**: Click "Generate Random Frog" to create your companion
2. **Review Stats**: Each frog has Strength, Agility, Intelligence, Magic, and Luck
3. **Start Adventure**: Click "Start Adventure" to begin an AI-generated scenario
4. **Make Choices**: Select from risk-based options that utilize different stats
5. **Manage Resources**: Keep your frog's energy and happiness high
6. **Repeat**: Each adventure is unique based on your frog's capabilities

### API Endpoints

The game provides RESTful API endpoints:

- `GET /` - Homepage with frog generation
- `GET /game` - Main game interface
- `POST /api/frog/generate` - Generate new frog companion
- `POST /api/adventure/start` - Begin new adventure scenario
- `POST /api/adventure/choice` - Process adventure choice
- `GET /health` - Health check endpoint

### Frog Generation System

Each frog is generated with:
- **Randomized Stats**: Balanced distribution across 5 attributes
- **Unique Abilities**: Powers that reflect their strongest stats
- **Personality Traits**: Behavioral characteristics affecting scenarios
- **Rich Backstories**: AI-generated origins explaining their capabilities

### Adventure Mechanics

Adventures adapt to your frog's stats:
- **High Strength**: More physical challenge options
- **High Intelligence**: Puzzle-solving and strategic choices
- **High Magic**: Mystical and supernatural approaches
- **High Agility**: Speed and stealth-based solutions
- **High Luck**: Serendipitous and fortunate outcomes

## 🧪 Development Commands

### Running Tests
```bash
# Run RSpec tests
bundle exec rspec

# Run with coverage
bundle exec rspec --require spec_helper
```

### Code Quality
```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -A
```

### Server Management
```bash
# Check running servers
lsof -i :4567

# Stop background server
pkill -f "rackup.*4567"

# View server logs
tail -f server.log
```

## 🏗 Project Structure

```
frog-adventure-game/
├── lib/frog/adventure/web/          # Core Ruby application
│   ├── app.rb                       # Main Sinatra app
│   ├── game_engine.rb              # Game logic
│   ├── llm_client.rb               # AI integration
│   ├── routes.rb                   # API endpoints
│   └── models.rb                   # Data structures
├── public/                         # Frontend assets
│   ├── css/                        # Stylesheets
│   ├── js/                         # JavaScript
│   └── images/                     # Game assets
├── views/                          # ERB templates
├── spec/                           # RSpec tests
├── config.ru                      # Rack configuration
├── docker-compose.yml             # Docker setup
└── CLAUDE.md                      # Development guidelines
```

## 🔧 Configuration

### Environment Variables

- `RACK_ENV`: Environment mode (development/production)
- `SESSION_SECRET`: Secure session encryption key
- `REDIS_URL`: Redis connection string (optional)
- `OLLAMA_API_BASE`: Ollama server URL (default: http://localhost:11434)
- `LLM_PROVIDER`: AI provider (default: ollama)
- `OLLAMA_MODEL`: Model name (default: gemma3n:e4b)

### LLM Configuration

The application uses Ollama for local AI generation:
- **Default Model**: gemma3n:e4b (4-bit quantized Gemma)
- **Fallback System**: Predefined content when AI is unavailable
- **Structured Outputs**: JSON format for consistent parsing
- **Error Handling**: Graceful degradation with retry logic

## 🤝 Contributing

### Development Workflow

1. **Check the Project Board**: https://github.com/users/jeremedia/projects/3
2. **Create Feature Branch**: `feature/issue-{number}-{description}`
3. **Follow Code Standards**: Use RuboCop and write tests
4. **Update Documentation**: Modify CLAUDE.md for significant changes
5. **Create Pull Request**: Link to relevant issue

### Multi-Agent Collaboration

This project supports multi-agent development. See `CLAUDE.md` for detailed protocols including:
- Issue claiming and assignment process
- Code standards and testing requirements
- Handoff procedures for incomplete work
- Architecture decision documentation

### Code Standards

- **Ruby Style**: Follow the Ruby Style Guide
- **Testing**: Write RSpec tests for all game logic
- **Documentation**: Use YARD for public APIs
- **Security**: Never commit secrets or API keys
- **Performance**: Optimize for concurrent users

## 📊 Monitoring & Debugging

### Server Logs
```bash
# View real-time logs
tail -f server.log

# Search for errors
grep -i error server.log

# Monitor LLM calls
grep "LLM" server.log
```

### Health Monitoring
- Health endpoint: `/health`
- Returns JSON with system status
- Monitors LLM connectivity and response times

### Common Issues

1. **LLM Generation Fails**: Check Ollama server status
2. **Host Not Permitted**: Configure Rack::Protection for your domain
3. **Session Errors**: Verify SESSION_SECRET is set
4. **Performance Issues**: Monitor LLM response times (10-15 seconds normal)

## 📈 Performance

### Optimization Features
- **Gzip Compression**: Rack::Deflater for response compression
- **Static File Caching**: Browser cache headers for assets
- **Session Management**: Efficient cookie-based sessions
- **Cache Busting**: Timestamp parameters for CSS/JS updates

### Scaling Considerations
- **Stateless Design**: Session data in cookies enables horizontal scaling
- **LLM Caching**: Consider Redis caching for repeated scenarios
- **CDN Support**: Static assets can be served via CDN
- **Load Balancing**: Multiple app instances can share Ollama backend

## 📄 License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 🙏 Acknowledgments

- **Ollama**: Local LLM inference engine
- **Gemma**: Google's open-source language model
- **Sinatra**: Lightweight Ruby web framework
- **Claude Code**: AI-assisted development platform

---

*Built with ❤️ and 🐸 by Jeremy using AI-assisted development*