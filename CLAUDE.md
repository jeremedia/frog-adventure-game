# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## CRITICAL: Screenshot Requirements for Web Development

**THIS IS MANDATORY - NOT OPTIONAL**

When developing ANY web UI features, you MUST follow these screenshot practices:

### 1. Take Screenshots at Key Points
- **Before any UI change**: Capture the current state
- **After making changes**: Capture the new state
- **After user interactions**: Capture results of clicks, form submissions, etc.
- **When investigating issues**: Always screenshot the actual state

### 2. ALWAYS Load and View Screenshots
- **NEVER assume what a screenshot shows**
- **ALWAYS use the Read tool to load the screenshot file immediately after taking it**
- **ALWAYS analyze what you actually see, not what you expect to see**
- Example workflow:
  ```
  1. Take screenshot: mcp__playwright__playwright_screenshot
  2. Load screenshot: Read tool with the saved file path
  3. Analyze: Look at the actual visual output step-by-step
  4. Verify: Compare what you see against what was intended
  ```

### 3. Screenshot Analysis Checklist
When viewing a screenshot, systematically check:
- [ ] Are all expected elements visible?
- [ ] Are elements in the correct positions?
- [ ] Do buttons/links appear clickable?
- [ ] Are there any unexpected gaps or overlaps?
- [ ] Does the layout match the intended design?
- [ ] Are there any error messages or console errors visible?

### 4. Why This Matters
- **You are building for HUMANS who will SEE the interface**
- **Code changes don't guarantee visual results**
- **Hidden elements, CSS conflicts, and JavaScript errors are only visible through screenshots**
- **Assumptions about UI state lead to broken user experiences**

### 5. Common Pitfalls to Avoid
- ❌ Taking screenshots but not viewing them
- ❌ Assuming code changes worked without visual verification
- ❌ Claiming to see elements that aren't actually visible
- ❌ Not checking browser console for errors when UI doesn't work

### Remember: If you haven't looked at a screenshot, you haven't verified the UI!

## Project Overview
Frog Adventure Web - A Ruby gem-based roguelike web application where frog companion stats dramatically change adventures, transforming gameplay into AI-generated cartoons.

**Game Concept**: This is a roguelike where the stats and abilities of your companion frog dramatically change the adventure. When the adventure completes, the game's series of steps is turned into a text narrative → storyboard → screenplay → cartoon via language model interactions.

**GitHub Project Board**: https://github.com/users/jeremedia/projects/3

**Current Status**: Phase 2.5 implementation - Enhanced frog generation and narrative pipeline development (48 total issues).

## Development Commands

### Running the Original Python Game
```bash
python3 frog_adventure.py
```

### Ruby Web Version (In Development)
```bash
# Install dependencies
bundle install

# Run development server (background)
bundle exec rackup -p 4567 -D

# Run development server (foreground, blocking)
bundle exec rackup -p 4567

# Stop background server
pkill -f "rackup.*4567"

# Check if server is running
lsof -i :4567

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop

# Run automated game tests
cd tests && npm test
```

## Architecture Overview

### Ruby Web Version (New)
- **Frog::Adventure::Web::App** (`lib/frog/adventure/web/app.rb`): Sinatra web application
- **Frog::Adventure::Web::GameEngine** (`lib/frog/adventure/web/game_engine.rb`): Core game logic
- **Frog::Adventure::Web::LLMClient** (`lib/frog/adventure/web/llm_client.rb`): Multi-provider LLM integration
- **State Management**: Redis-based persistence for web sessions

### Original Python Version
- **Main Game Loop** (`frog_adventure.py`): Single-file implementation containing all game logic
- **AI Integration**: Uses OpenAI API for dynamic frog generation with structured outputs via Pydantic
- **Fallback System**: Predefined frog data when AI is unavailable
- **State Management**: JSON-based save/load system for game persistence

### Key Design Patterns
1. **Structured AI Responses**: Uses Pydantic models (`FrogResponse`) to ensure consistent AI outputs
2. **Graceful Degradation**: Falls back to predefined frogs when OpenAI API is unavailable
3. **Energy/Happiness Mechanics**: Virtual pet simulation requiring player interaction
4. **Environment-based Configuration**: API key from `OPENAI_API_KEY` environment variable

### Data Models

#### Roguelike Core
- **Frog Companions**: Procedurally generated with stats that affect adventure mechanics
- **Adventure System**: Turn-based encounters with choices influenced by frog abilities
- **Progression**: Adventures unlock new regions and companion types

#### Narrative Generation Pipeline
- **Adventure Log**: Records player choices, outcomes, and story beats during gameplay
- **Text Narrative**: AI transforms adventure log into coherent story prose
- **Storyboard**: Converts narrative into visual scene descriptions
- **Screenplay**: Formats scenes into dialogue and action sequences
- **Cartoon Generation**: Produces final animated content from screenplay

#### Legacy Data Models (Python)
- `FrogDifficulty` (Enum): TINY, SMALL, MEDIUM, LARGE, GIANT
- `FrogPersonality` (Enum): FRIENDLY, NEUTRAL, GRUMPY, MYSTERIOUS
- `Frog` (dataclass): Core frog attributes including AI-generated descriptions
- `GameState` (dataclass): Player inventory, stats, and current frog

## Important Implementation Details
- AI generation uses `gpt-4o-mini` model with structured output format
- Save files stored as `frog_adventure_save.json` in working directory
- Combat system uses turn-based mechanics with randomized damage
- Special endings triggered by specific frog combinations

## Interactive Features

### Frog Preview System
The web application includes an interactive frog companion preview system that allows players to generate and preview randomly-generated frogs before starting adventures.

**Key Components:**
- **API Endpoint**: `POST /api/frog/generate` - RESTful endpoint for frog generation
- **Frontend UI**: Interactive button with real-time frog display and animated stat bars
- **Responsive Design**: Mobile-friendly frog cards with CSS animations
- **Error Handling**: Graceful fallbacks for network errors and API failures
- **Randomization**: 6 unique mock frogs with varied abilities, species, and backstories

**Technical Implementation:**
- **Backend**: Sinatra routes with JSON responses, proper error handling
- **Frontend**: Vanilla JavaScript with fetch API for AJAX calls
- **Styling**: Custom CSS with animated progress bars and loading states
- **Mock Data**: Rich frog variations including Sparky, Bubbles, Rocky, Whisper, Prism, and Sage
- **Stats Display**: Visual representation of Strength, Agility, Intelligence, Magic, and Luck

**Files Modified:**
- `lib/frog/adventure/web/routes.rb` - Added frog generation API endpoint
- `views/index.erb` - Enhanced homepage with interactive preview section
- `public/css/style.css` - Added frog card styling and animations (272 lines)
- `public/js/app.js` - Complete rewrite for interactive functionality
- `lib/frog/adventure/web/llm_client.rb` - Randomized mock frog generation

This feature provides immediate visual feedback and demonstrates the game's frog generation system without requiring full gameplay implementation.

## Multi-Agent Collaboration Protocol

### Starting Work
1. Check the [Project Board](https://github.com/users/jeremedia/projects/3) for available work
2. Only claim issues marked `ready-to-work`
3. Assign yourself and move to "In Progress"
4. Work on feature branch: `feature/issue-{number}-{description}`
5. Comment: "🤖 Agent [session-id] starting work"

### Code Standards
- Use Ruby 3.2+ features
- Follow Ruby Style Guide
- Write RSpec tests for all game logic
- Use YARD documentation for public APIs
- Commit often with descriptive messages

### LLM Integration Patterns
- Use rubyllm's streaming for real-time responses
- Implement exponential backoff for API failures
- Cache LLM responses with 24-hour TTL
- Always provide fallback content

### Testing Requirements
- Unit tests for all game logic (RSpec)
- Integration tests for API endpoints (Rack::Test)
- Feature tests for critical paths (Capybara)
- Minimum 80% code coverage

### Handoff Protocol
If unable to complete an issue:
1. Commit all work with detailed message
2. Update issue with progress and blockers
3. Document any architectural decisions
4. Remove self-assignment
5. Add `help-wanted` label

### Architecture Decisions
- For major decisions, create ADR issue first
- Link ADR to implementation issues
- Update `/docs/architecture/` with decision

### Issue Dependencies
Check issue descriptions for "Depends on:" references. Do not start work on issues with unmet dependencies.

### Progress Updates
- Comment on issue every 30 minutes with progress
- Use task lists in comments to track sub-tasks
- Update issue description if scope changes

### PR Guidelines
1. Create draft PR early with issue number in title
2. Link PR to issue with "Closes #XX"
3. Ensure all tests pass
4. Update documentation as needed
5. Request review when ready

## Concrete Example: Issue #1 Workflow

Here's how Issue #1 was completed following the protocol:

### 1. Claiming Work
```bash
# Check issue details
gh issue view 1 --json number,title,labels,body

# Assign to self
gh issue edit 1 --add-assignee @me

# Comment on issue
gh issue comment 1 --body "🤖 Agent claude-3-5-sonnet-20241022 starting work..."

# Create feature branch
git checkout -b feature/issue-1-gem-structure
```

### 2. During Work
- Created TodoWrite list to track acceptance criteria
- Implemented each requirement systematically
- Used proper Ruby gem conventions
- Committed with descriptive message

### 3. Completing Work
```bash
# Commit all changes
git add -A
git commit -m "Initialize Ruby gem structure..."

# Push branch
git push -u origin feature/issue-1-gem-structure

# Create PR
gh pr create --title "[FEATURE] Initialize Ruby gem structure..." \
  --body "## Summary..."
```

### 4. Result
- PR #26 created and linked to Issue #1
- Clear documentation for next agents
- Unblocked issues #2, #6 for other agents to pick up
- All work preserved in feature branch

This demonstrates the complete workflow from claiming to handoff.