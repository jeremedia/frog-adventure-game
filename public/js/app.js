// Frog Adventure Web - Main JavaScript

class FrogAdventureGame {
  constructor() {
    this.gameId = null;
    this.gameState = null;
    this.eventSource = null;
    
    this.init();
  }
  
  init() {
    console.log('🐸 Frog Adventure Web initialized!');
    
    // Get DOM elements
    this.startButton = document.getElementById('start-game');
    
    // Add event listeners
    if (this.startButton) {
      this.startButton.addEventListener('click', () => this.startNewGame());
    }
    
    // Check for saved game
    this.checkSavedGame();
  }
  
  async checkSavedGame() {
    const savedGameId = localStorage.getItem('frogAdventureGameId');
    if (savedGameId) {
      try {
        const response = await fetch(`/api/game/${savedGameId}`);
        if (response.ok) {
          const data = await response.json();
          this.gameId = savedGameId;
          this.gameState = data;
          console.log('Loaded saved game:', this.gameId);
        }
      } catch (error) {
        console.error('Failed to load saved game:', error);
      }
    }
  }
  
  async startNewGame() {
    try {
      this.startButton.disabled = true;
      this.startButton.textContent = 'Creating your frog companion...';
      
      const response = await fetch('/api/game/new', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      if (response.ok) {
        const data = await response.json();
        this.gameId = data.gameId;
        this.gameState = data.gameState;
        
        // Save game ID
        localStorage.setItem('frogAdventureGameId', this.gameId);
        
        console.log('New game started:', this.gameId);
        this.startButton.textContent = 'Game Started!';
        
        // TODO: Redirect to game view
      } else {
        throw new Error('Failed to start game');
      }
    } catch (error) {
      console.error('Error starting game:', error);
      this.startButton.textContent = 'Start Adventure (Coming Soon)';
      this.startButton.disabled = true;
    }
  }
  
  async performAction(action, data = {}) {
    if (!this.gameId) return;
    
    try {
      const response = await fetch(`/api/game/${this.gameId}/action`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ action, data })
      });
      
      if (response.ok) {
        const result = await response.json();
        this.updateGameState(result.gameState);
        return result;
      }
    } catch (error) {
      console.error('Error performing action:', error);
    }
  }
  
  updateGameState(newState) {
    this.gameState = newState;
    // TODO: Update UI with new state
    console.log('Game state updated:', this.gameState);
  }
  
  connectToSSE() {
    if (!this.gameId) return;
    
    this.eventSource = new EventSource(`/api/game/${this.gameId}/events`);
    
    this.eventSource.onmessage = (event) => {
      const data = JSON.parse(event.data);
      this.handleServerEvent(data);
    };
    
    this.eventSource.onerror = (error) => {
      console.error('SSE connection error:', error);
      this.reconnectSSE();
    };
  }
  
  handleServerEvent(event) {
    console.log('Server event:', event);
    
    switch (event.type) {
      case 'state_update':
        this.updateGameState(event.data);
        break;
      case 'adventure_complete':
        // TODO: Show adventure results
        break;
      case 'frog_mood_change':
        // TODO: Update frog display
        break;
    }
  }
  
  reconnectSSE() {
    if (this.eventSource) {
      this.eventSource.close();
    }
    
    setTimeout(() => {
      console.log('Reconnecting to server...');
      this.connectToSSE();
    }, 5000);
  }
}

// Initialize game when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  window.frogGame = new FrogAdventureGame();
});