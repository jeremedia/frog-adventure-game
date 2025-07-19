# 🐸 Frog Adventure Game

A fun adventure game where you explore with a different frog companion each time! Now featuring AI-generated unique frogs using OpenAI's structured outputs.

## Features

- **AI-Generated Frogs**: Each run creates a completely unique frog with personality, backstory, and special abilities
- **Fallback Mode**: Works without OpenAI API key using pre-defined frog types
- **Adventure Scenarios**: Multiple random adventures to explore
- **Save/Load System**: Continue your adventures later
- **Energy & Happiness**: Manage your frog's well-being

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. (Optional) Set up OpenAI API key for AI-generated frogs:
```bash
export OPENAI_API_KEY="your-api-key-here"
```

## Running the Game

```bash
python3 frog_adventure.py
```

## How to Play

1. Meet your randomly generated frog companion
2. Go on adventures and make choices
3. Use your frog's special ability to overcome challenges
4. Rest to restore energy and feed to increase happiness
5. Collect items and complete adventures
6. Save your progress anytime

## AI Frog Generation

When OpenAI API is configured, frogs are generated with:
- Unique names and species
- Detailed appearance and personality
- Creative special abilities
- Interesting backstories
- Custom traits and quirks

Without API key, the game uses 6 pre-defined frog types with their own abilities.