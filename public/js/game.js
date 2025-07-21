// Game UI Components

class GameUI {
  constructor() {
    this.currentFrog = null;
    this.gameState = {
      energy: 100,
      happiness: 75,
      adventures: 0,
      inventory: []
    };
    this.adventureLog = [];
    this.init();
  }

  init() {
    console.log('🎮 Game UI initialized!');
    this.setupEventListeners();
    this.loadCurrentFrog();
    this.updateStatusBars();
  }

  setupEventListeners() {
    // Start Adventure button
    const startBtn = document.getElementById('start-adventure-btn');
    if (startBtn) {
      startBtn.addEventListener('click', () => this.startAdventure());
    }

    // Quick action buttons
    document.getElementById('feed-frog')?.addEventListener('click', () => this.feedFrog());
    document.getElementById('play-frog')?.addEventListener('click', () => this.playWithFrog());
    document.getElementById('rest-frog')?.addEventListener('click', () => this.restFrog());

    // Modal buttons
    document.getElementById('new-game-btn')?.addEventListener('click', () => this.startNewGame());
    document.getElementById('main-menu-btn')?.addEventListener('click', () => this.returnToMenu());
  }

  loadCurrentFrog() {
    // Try to load frog from session or local storage
    const savedFrog = localStorage.getItem('currentFrog');
    if (savedFrog) {
      this.currentFrog = JSON.parse(savedFrog);
      this.displayFrog(this.currentFrog);
    } else {
      // Redirect to main page if no frog selected
      this.showMessage('No frog selected! Redirecting to main menu...', 'warning');
      setTimeout(() => {
        window.location.href = '/';
      }, 2000);
    }
  }

  displayFrog(frog) {
    // Update frog card
    document.getElementById('game-frog-name').textContent = frog.name;
    document.getElementById('game-frog-type').textContent = frog.type;
    
    // Update stats
    document.getElementById('game-strength').textContent = frog.stats.strength;
    document.getElementById('game-agility').textContent = frog.stats.agility;
    document.getElementById('game-intelligence').textContent = frog.stats.intelligence;
    document.getElementById('game-magic').textContent = frog.stats.magic;
    document.getElementById('game-luck').textContent = frog.stats.luck;
    
    // Update ability
    document.getElementById('game-ability').textContent = frog.ability;
    
    // Animate frog avatar
    const frogEmoji = document.querySelector('.frog-emoji');
    if (frogEmoji) {
      frogEmoji.style.animation = 'none';
      setTimeout(() => {
        frogEmoji.style.animation = 'float 3s ease-in-out infinite';
      }, 100);
    }
  }

  updateStatusBars() {
    // Update energy bar
    const energyBar = document.getElementById('energy-bar');
    const energyValue = document.getElementById('energy-value');
    if (energyBar && energyValue) {
      energyBar.style.width = `${this.gameState.energy}%`;
      energyValue.textContent = `${this.gameState.energy}/100`;
      
      // Change color based on energy level
      if (this.gameState.energy < 30) {
        energyBar.style.background = 'linear-gradient(to right, #ef4444, #dc2626)';
      }
    }
    
    // Update happiness bar
    const happinessBar = document.getElementById('happiness-bar');
    const happinessValue = document.getElementById('happiness-value');
    if (happinessBar && happinessValue) {
      happinessBar.style.width = `${this.gameState.happiness}%`;
      happinessValue.textContent = `${this.gameState.happiness}/100`;
      
      // Change color based on happiness level
      if (this.gameState.happiness < 30) {
        happinessBar.style.background = 'linear-gradient(to right, #ef4444, #dc2626)';
      }
    }
    
    // Update adventure count
    const adventureCount = document.getElementById('adventure-count');
    if (adventureCount) {
      adventureCount.textContent = this.gameState.adventures;
    }
  }

  async startAdventure() {
    if (this.gameState.energy < 20) {
      this.showMessage('Your frog is too tired! Rest or feed your frog first.', 'warning');
      return;
    }
    
    // Get the button and disable it
    const startBtn = document.getElementById('start-adventure-btn');
    if (startBtn) {
      startBtn.disabled = true;
      startBtn.classList.add('loading');
      startBtn.innerHTML = '<span class="spinner"></span> Loading Adventure...';
    }
    
    this.addLogEntry('Starting a new adventure...');
    
    // Show loading message in scenario area
    const titleEl = document.getElementById('scenario-title');
    const textEl = document.getElementById('scenario-text');
    const choicesEl = document.getElementById('choices-container');
    
    if (titleEl) titleEl.textContent = 'Loading...';
    if (textEl) textEl.innerHTML = '<p>Your frog is discovering a new adventure...</p>';
    if (choicesEl) choicesEl.innerHTML = '';
    
    try {
      const response = await fetch('/api/adventure/start', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          frog_id: this.currentFrog.id,
          frog_stats: this.currentFrog.stats
        })
      });
      
      const result = await response.json();
      
      if (result.status === 'success') {
        this.currentScenario = result.scenario;
        this.displayScenario(result.scenario);
        this.gameState.energy -= 20;
        this.gameState.adventures += 1;
        this.updateStatusBars();
      } else {
        this.showMessage('Failed to start adventure. Please try again.', 'error');
        // Re-enable button on error
        if (startBtn) {
          startBtn.disabled = false;
          startBtn.classList.remove('loading');
          startBtn.innerHTML = 'Begin Adventure';
        }
      }
    } catch (error) {
      console.error('Adventure error:', error);
      // Fallback to demo scenario
      this.displayDemoScenario();
    }
  }

  displayScenario(scenario) {
    const titleEl = document.getElementById('scenario-title');
    const textEl = document.getElementById('scenario-text');
    const choicesEl = document.getElementById('choices-container');
    
    // Animate scenario change
    titleEl.style.animation = 'fadeIn 0.5s ease-out';
    textEl.style.animation = 'fadeIn 0.5s ease-out 0.2s both';
    
    titleEl.textContent = scenario.title;
    textEl.innerHTML = `<p>${scenario.description}</p>`;
    
    // Clear and add choice buttons
    choicesEl.innerHTML = '';
    scenario.choices.forEach((choice, index) => {
      const btn = document.createElement('button');
      btn.className = 'choice-button';
      btn.textContent = choice.text;
      btn.addEventListener('click', () => this.makeChoice(choice.id));
      
      // Stagger animation
      btn.style.animation = `slideIn 0.3s ease-out ${0.1 * index}s both`;
      choicesEl.appendChild(btn);
    });
  }

  displayDemoScenario() {
    // Demo scenario for when backend isn't ready
    const demoScenario = {
      title: "The Mysterious Pond",
      description: "Your frog discovers a shimmering pond deep in the forest. The water glows with an otherworldly light, and you can hear faint whispers coming from beneath the surface.",
      choices: [
        { id: 1, text: "🏊 Dive into the glowing water" },
        { id: 2, text: "🔍 Investigate the whispers carefully" },
        { id: 3, text: "🍄 Look for magical mushrooms nearby" },
        { id: 4, text: "🏃 This seems dangerous, hop away!" }
      ]
    };
    
    this.displayScenario(demoScenario);
    this.gameState.energy -= 20;
    this.gameState.adventures += 1;
    this.updateStatusBars();
  }

  async makeChoice(choiceId) {
    this.addLogEntry(`Made choice: Option ${choiceId}`);
    
    // Animate choice selection
    const buttons = document.querySelectorAll('.choice-button');
    buttons.forEach(btn => {
      btn.disabled = true;
      btn.style.opacity = '0.5';
    });
    
    try {
      // Make real API call to process choice
      const response = await fetch('/api/adventure/choice', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          scenario_id: this.currentScenario?.id,
          choice: { id: choiceId, risk: 'medium' },
          frog_stats: this.currentFrog?.stats || {}
        })
      });
      
      const result = await response.json();
      
      if (result.status === 'success') {
        const outcome = result.outcome;
        this.showOutcome(outcome.message);
        
        // Update stats based on outcome
        if (outcome.energy_change) {
          this.gameState.energy = Math.max(0, Math.min(100, this.gameState.energy + outcome.energy_change));
        }
        if (outcome.happiness_change) {
          this.gameState.happiness = Math.max(0, Math.min(100, this.gameState.happiness + outcome.happiness_change));
        }
        if (outcome.item) {
          this.gameState.inventory.push(outcome.item);
          this.updateInventory();
        }
        
        this.updateStatusBars();
        
        // Show continue button
        const choicesEl = document.getElementById('choices-container');
        choicesEl.innerHTML = '';
        const continueBtn = document.createElement('button');
        continueBtn.className = 'choice-button primary';
        continueBtn.textContent = 'Continue Adventure';
        continueBtn.addEventListener('click', () => this.continueAdventure());
        choicesEl.appendChild(continueBtn);
      } else {
        this.showMessage('Failed to process choice. Please try again.', 'error');
      }
    } catch (error) {
      console.error('Choice error:', error);
      // Fallback to demo outcome
      const outcomes = [
        "You found a magical lily pad! +10 happiness!",
        "You discovered ancient frog wisdom! +5 intelligence!",
        "You encountered a friendly turtle who shared food! +15 energy!",
        "You barely escaped a hungry heron! -10 energy but gained experience!"
      ];
      
      const outcome = outcomes[Math.floor(Math.random() * outcomes.length)];
      this.showOutcome(outcome);
      
      // Update stats based on outcome
      if (outcome.includes('happiness')) {
        this.gameState.happiness = Math.min(100, this.gameState.happiness + 10);
      } else if (outcome.includes('energy')) {
        this.gameState.energy = Math.max(0, this.gameState.energy - 10);
      }
      
      this.updateStatusBars();
      
      // Show continue button
      const choicesEl = document.getElementById('choices-container');
      choicesEl.innerHTML = '';
      const continueBtn = document.createElement('button');
      continueBtn.className = 'choice-button primary';
      continueBtn.textContent = 'Continue Adventure';
      continueBtn.addEventListener('click', () => this.continueAdventure());
      choicesEl.appendChild(continueBtn);
    }
  }

  showOutcome(outcome) {
    const textEl = document.getElementById('scenario-text');
    textEl.innerHTML = `<p class="outcome-text">${outcome}</p>`;
    textEl.style.animation = 'fadeIn 0.5s ease-out';
    
    this.addLogEntry(outcome);
    
    // Add item to inventory if applicable
    if (outcome.includes('found')) {
      this.addInventoryItem('🌸', 'Magical Lily Pad');
    }
  }

  continueAdventure() {
    if (this.gameState.energy >= 20) {
      this.startAdventure();
    } else {
      this.showMessage('Your frog needs rest! Use the quick actions below.', 'info');
      this.resetToStart();
    }
  }

  resetToStart() {
    document.getElementById('scenario-title').textContent = 'Ready for Adventure!';
    document.getElementById('scenario-text').innerHTML = '<p>Your frog is ready for the next adventure. Make sure to keep your energy and happiness high!</p>';
    
    const choicesEl = document.getElementById('choices-container');
    choicesEl.innerHTML = '';
    const startBtn = document.createElement('button');
    startBtn.id = 'start-adventure-btn';
    startBtn.className = 'choice-button primary';
    startBtn.textContent = 'Begin Adventure';
    startBtn.disabled = false;
    startBtn.classList.remove('loading');
    startBtn.addEventListener('click', () => this.startAdventure());
    choicesEl.appendChild(startBtn);
  }

  // Quick Actions
  feedFrog() {
    if (this.gameState.energy >= 100) {
      this.showMessage('Your frog is already full of energy!', 'info');
      return;
    }
    
    this.gameState.energy = Math.min(100, this.gameState.energy + 25);
    this.gameState.happiness = Math.min(100, this.gameState.happiness + 10);
    this.updateStatusBars();
    
    this.addLogEntry('Fed your frog. Energy +25, Happiness +10!');
    this.animateFrog('bounce');
  }

  playWithFrog() {
    if (this.gameState.energy < 10) {
      this.showMessage('Your frog is too tired to play!', 'warning');
      return;
    }
    
    this.gameState.energy = Math.max(0, this.gameState.energy - 10);
    this.gameState.happiness = Math.min(100, this.gameState.happiness + 20);
    this.updateStatusBars();
    
    this.addLogEntry('Played with your frog. Happiness +20!');
    this.animateFrog('spin');
  }

  restFrog() {
    this.gameState.energy = Math.min(100, this.gameState.energy + 40);
    this.gameState.happiness = Math.min(100, this.gameState.happiness + 5);
    this.updateStatusBars();
    
    this.addLogEntry('Your frog took a nice nap. Energy +40!');
    this.animateFrog('pulse');
  }

  animateFrog(animation) {
    const frogEmoji = document.querySelector('.frog-emoji');
    if (frogEmoji) {
      frogEmoji.style.animation = 'none';
      setTimeout(() => {
        if (animation === 'bounce') {
          frogEmoji.style.animation = 'bounce 0.5s ease-out';
        } else if (animation === 'spin') {
          frogEmoji.style.animation = 'spin 0.5s ease-out';
        } else if (animation === 'pulse') {
          frogEmoji.style.animation = 'pulse 0.5s ease-out 3';
        }
        
        setTimeout(() => {
          frogEmoji.style.animation = 'float 3s ease-in-out infinite';
        }, 600);
      }, 100);
    }
  }

  // Inventory Management
  addInventoryItem(icon, name, count = 1) {
    const grid = document.getElementById('inventory-grid');
    
    // Check if item already exists
    const existingItem = Array.from(grid.children).find(item => 
      item.dataset.name === name
    );
    
    if (existingItem) {
      const countEl = existingItem.querySelector('.item-count');
      const currentCount = parseInt(countEl.textContent) || 1;
      countEl.textContent = currentCount + count;
    } else {
      const item = document.createElement('div');
      item.className = 'inventory-item';
      item.dataset.name = name;
      item.innerHTML = `
        ${icon}
        ${count > 1 ? `<span class="item-count">${count}</span>` : ''}
      `;
      item.title = name;
      grid.appendChild(item);
    }
  }

  // Adventure Log
  addLogEntry(text) {
    const logEntries = document.getElementById('log-entries');
    const entry = document.createElement('div');
    entry.className = 'log-entry';
    
    const time = new Date().toLocaleTimeString('en-US', { 
      hour: 'numeric', 
      minute: '2-digit' 
    });
    
    entry.innerHTML = `
      <span class="log-time">${time}</span>
      <span class="log-text">${text}</span>
    `;
    
    logEntries.insertBefore(entry, logEntries.firstChild);
    
    // Keep only last 20 entries
    while (logEntries.children.length > 20) {
      logEntries.removeChild(logEntries.lastChild);
    }
  }

  // UI Helpers
  showMessage(message, type = 'info') {
    const colors = {
      info: '#3b82f6',
      warning: '#f59e0b',
      error: '#ef4444',
      success: '#10b981'
    };
    
    const textEl = document.getElementById('scenario-text');
    textEl.innerHTML = `
      <p style="color: ${colors[type]}; font-weight: bold; text-align: center;">
        ${message}
      </p>
    `;
  }

  // Game Over
  checkGameOver() {
    if (this.gameState.happiness <= 0) {
      this.showGameOver('Your frog became too sad to continue...', false);
    } else if (this.gameState.adventures >= 10 && this.gameState.happiness >= 80) {
      this.showGameOver('Your frog achieved legendary status!', true);
    }
  }

  showGameOver(message, isWin) {
    const modal = document.getElementById('game-over-modal');
    const title = document.getElementById('game-over-title');
    const messageEl = document.getElementById('game-over-message');
    
    title.textContent = isWin ? '🎉 Victory!' : '😢 Game Over';
    messageEl.textContent = message;
    
    modal.classList.remove('hidden');
  }

  startNewGame() {
    localStorage.removeItem('currentFrog');
    window.location.href = '/';
  }

  returnToMenu() {
    window.location.href = '/';
  }
}

// Additional animations
const style = document.createElement('style');
style.textContent = `
  @keyframes bounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-20px); }
  }
  
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
  
  @keyframes pulse {
    0%, 100% { transform: scale(1); }
    50% { transform: scale(1.2); }
  }
  
  .outcome-text {
    font-size: 1.25rem;
    font-weight: bold;
    text-align: center;
    color: #fbbf24;
  }
`;
document.head.appendChild(style);

// Initialize game UI when page loads
document.addEventListener('DOMContentLoaded', () => {
  if (document.querySelector('.game-container')) {
    window.gameUI = new GameUI();
  }
});