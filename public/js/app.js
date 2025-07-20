// Frog Adventure Web - Main JavaScript

class FrogAdventureGame {
  constructor() {
    this.gameState = null;
    this.websocket = null;
    this.currentFrog = null;
    this.init();
  }

  init() {
    console.log('🐸 Frog Adventure Game initialized!');
    
    // Initialize game UI
    this.setupEventListeners();
    this.checkGameStatus();
  }

  setupEventListeners() {
    // Add event listeners for game controls
    const startButton = document.getElementById('start-game');
    if (startButton) {
      startButton.addEventListener('click', () => this.startNewGame());
    }

    // Frog generation controls
    const generateButton = document.getElementById('generate-frog');
    if (generateButton) {
      generateButton.addEventListener('click', () => this.generateRandomFrog());
    }
  }

  async checkGameStatus() {
    try {
      const response = await fetch('/health');
      const status = await response.json();
      console.log('Game status:', status);
    } catch (error) {
      console.error('Failed to check game status:', error);
    }
  }

  async generateRandomFrog() {
    try {
      // Show loading state
      this.showLoading(true);
      this.hideFrogDisplay();

      // Get selected frog type
      const typeSelector = document.getElementById('frog-type-selector');
      const selectedType = typeSelector ? typeSelector.value : '';

      // Prepare request body
      const requestBody = selectedType ? { frog_type: selectedType } : {};

      const response = await fetch('/api/frog/generate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestBody)
      });

      const result = await response.json();
      
      if (result.status === 'success') {
        this.currentFrog = result.frog;
        this.displayFrog(result.frog);
        console.log('Generated frog:', result.frog);
      } else {
        console.error('Failed to generate frog:', result.message);
        this.showError('Failed to generate frog. Please try again.');
      }
    } catch (error) {
      console.error('Error generating frog:', error);
      this.showError('Network error. Please check your connection.');
    } finally {
      this.showLoading(false);
    }
  }

  displayFrog(frog) {
    // Update frog header
    document.getElementById('frog-name').textContent = frog.name;
    document.getElementById('frog-type').textContent = frog.type;

    // Update description and species
    document.getElementById('frog-description').textContent = frog.description;
    document.getElementById('frog-species').textContent = frog.species || 'Unknown';

    // Update stats with animated bars
    this.updateStats(frog.stats);

    // Update traits
    this.updateTraits(frog.traits);

    // Update ability
    document.getElementById('ability-name').textContent = frog.ability;
    const abilityPower = this.calculateAbilityPower(frog.stats.magic);
    document.getElementById('ability-power').textContent = `Power: ${abilityPower.toFixed(1)}`;

    // Update backstory
    document.getElementById('frog-backstory').textContent = frog.backstory || 'A mysterious frog with an unknown past...';

    // Show the frog card
    this.showFrogDisplay();
    
    // Show Start Adventure button
    const startButton = document.getElementById('start-game');
    if (startButton) {
      startButton.style.display = 'block';
      startButton.style.marginTop = '2rem';
    }
  }

  updateStats(stats) {
    const statNames = ['strength', 'agility', 'intelligence', 'magic', 'luck'];
    let total = 0;

    statNames.forEach(stat => {
      const value = stats[stat] || 0;
      total += value;

      // Update stat value
      document.getElementById(`${stat}-value`).textContent = value;

      // Animate stat bar
      const statBar = document.getElementById(`${stat}-bar`);
      const percentage = (value / 20) * 100; // Max stat is 20
      
      // Reset animation
      statBar.style.width = '0%';
      
      // Animate to actual value
      setTimeout(() => {
        statBar.style.width = `${percentage}%`;
      }, 100);
    });

    // Update total stats
    document.getElementById('total-stats').textContent = total;
  }

  updateTraits(traits) {
    const traitsContainer = document.getElementById('traits-list');
    traitsContainer.innerHTML = '';

    if (traits && traits.length > 0) {
      traits.forEach(trait => {
        const traitTag = document.createElement('span');
        traitTag.className = 'trait-tag';
        traitTag.textContent = trait;
        traitsContainer.appendChild(traitTag);
      });
    } else {
      traitsContainer.innerHTML = '<span class="trait-tag">Mysterious</span>';
    }
  }

  calculateAbilityPower(magicStat) {
    const basePower = 10;
    const magicBonus = magicStat / 20.0;
    return basePower * (1 + magicBonus);
  }

  showFrogDisplay() {
    const frogDisplay = document.getElementById('frog-display');
    frogDisplay.classList.remove('hidden');
  }

  hideFrogDisplay() {
    const frogDisplay = document.getElementById('frog-display');
    frogDisplay.classList.add('hidden');
  }

  showLoading(show) {
    const loadingIndicator = document.getElementById('loading-indicator');
    if (show) {
      loadingIndicator.classList.remove('hidden');
    } else {
      loadingIndicator.classList.add('hidden');
    }
  }

  showError(message) {
    // Create or update error display
    let errorDiv = document.getElementById('error-message');
    if (!errorDiv) {
      errorDiv = document.createElement('div');
      errorDiv.id = 'error-message';
      errorDiv.className = 'error-message';
      errorDiv.style.cssText = `
        background: #fee2e2;
        color: #dc2626;
        padding: 1rem;
        border-radius: 8px;
        margin: 1rem 0;
        border: 2px solid #fca5a5;
        text-align: center;
        font-weight: 600;
      `;
      document.querySelector('.frog-preview-section').appendChild(errorDiv);
    }
    
    errorDiv.textContent = message;
    errorDiv.style.display = 'block';
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
      errorDiv.style.display = 'none';
    }, 5000);
  }

  async startNewGame() {
    if (!this.currentFrog) {
      this.showError('Please generate a frog first!');
      return;
    }
    
    // Save current frog to localStorage
    localStorage.setItem('currentFrog', JSON.stringify(this.currentFrog));
    
    // Navigate to game page
    window.location.href = '/game';
  }

  async loadGame(gameId) {
    try {
      const response = await fetch(`/api/game/${gameId}`);
      const result = await response.json();
      
      if (result.status === 'success') {
        this.gameState = result.game;
        this.updateGameUI();
      }
    } catch (error) {
      console.error('Error loading game:', error);
    }
  }

  updateGameUI() {
    // Update the game interface with current state
    console.log('Updating game UI with state:', this.gameState);
  }
}

// Initialize the game when the page loads
document.addEventListener('DOMContentLoaded', () => {
  window.frogGame = new FrogAdventureGame();
});