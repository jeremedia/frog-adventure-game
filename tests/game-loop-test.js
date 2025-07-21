/**
 * Automated Game Loop Testing for Frog Adventure Game
 * 
 * This script tests the complete game flow from start to finish,
 * ensuring all components work correctly and the game is playable.
 */

class GameLoopTester {
  constructor() {
    this.gameState = null;
    this.testResults = [];
    this.screenshots = [];
    this.startTime = new Date();
  }

  log(message, type = 'info') {
    const timestamp = new Date().toISOString();
    const logEntry = { timestamp, message, type };
    this.testResults.push(logEntry);
    
    const prefix = type === 'error' ? '❌' : type === 'success' ? '✅' : 'ℹ️';
    console.log(`${prefix} [${timestamp}] ${message}`);
  }

  async takeScreenshot(name, description) {
    try {
      // Note: This will be called from Playwright context
      await page.screenshot({ 
        path: `test-screenshots/${name}-${Date.now()}.png`,
        fullPage: true 
      });
      this.screenshots.push({ name, description, timestamp: new Date() });
      this.log(`Screenshot captured: ${name}`, 'info');
    } catch (error) {
      this.log(`Failed to capture screenshot ${name}: ${error.message}`, 'error');
    }
  }

  async getGameState() {
    try {
      return await page.evaluate(() => {
        if (window.gameUI) {
          return {
            type: 'game',
            frog: window.gameUI.currentFrog,
            energy: window.gameUI.gameState.energy,
            happiness: window.gameUI.gameState.happiness,
            adventures: window.gameUI.gameState.adventures,
            inventory: window.gameUI.gameState.inventory
          };
        } else if (window.frogGame) {
          return {
            type: 'main',
            frog: window.frogGame.currentFrog
          };
        }
        return { type: 'unknown' };
      });
    } catch (error) {
      this.log(`Failed to get game state: ${error.message}`, 'error');
      return null;
    }
  }

  async testFrogGeneration() {
    this.log('Starting frog generation test...', 'info');
    
    try {
      // Navigate to main page
      await page.goto('http://localhost:4567/');
      await this.takeScreenshot('01-homepage', 'Initial homepage load');
      
      // Wait for page to load
      await page.waitForSelector('#generate-frog', { timeout: 5000 });
      
      // Click generate frog button
      this.log('Clicking Generate Random Frog button...', 'info');
      await page.click('#generate-frog');
      
      // Wait for frog to be generated
      await page.waitForTimeout(3000);
      
      // Check if frog was generated
      const frogState = await this.getGameState();
      if (frogState && frogState.frog) {
        this.log(`Frog generated successfully: ${frogState.frog.name} (${frogState.frog.type})`, 'success');
        await this.takeScreenshot('02-frog-generated', 'Frog successfully generated');
        
        // Scroll to find Start Adventure button
        await page.evaluate(() => {
          const button = document.getElementById('start-game');
          if (button) {
            button.scrollIntoView({ behavior: 'smooth', block: 'center' });
          }
        });
        
        await page.waitForTimeout(1000);
        await this.takeScreenshot('03-start-button-visible', 'Start Adventure button visible');
        
        return true;
      } else {
        this.log('Frog generation failed - no frog data found', 'error');
        return false;
      }
    } catch (error) {
      this.log(`Frog generation test failed: ${error.message}`, 'error');
      return false;
    }
  }

  async testGameNavigation() {
    this.log('Testing game navigation...', 'info');
    
    try {
      // Click Start Adventure button
      const buttonVisible = await page.$('#start-game');
      if (!buttonVisible) {
        this.log('Start Adventure button not found', 'error');
        return false;
      }
      
      this.log('Clicking Start Adventure button...', 'info');
      await page.click('#start-game');
      
      // Wait for navigation to game page
      await page.waitForURL('**/game', { timeout: 5000 });
      await page.waitForTimeout(2000);
      
      await this.takeScreenshot('04-game-ui-loaded', 'Game UI loaded successfully');
      
      // Verify game UI elements are present
      const gameElements = await page.evaluate(() => {
        return {
          statusBar: !!document.querySelector('.status-bar'),
          frogCard: !!document.querySelector('.frog-card-game'),
          adventureDisplay: !!document.querySelector('.adventure-display'),
          inventory: !!document.querySelector('.inventory-panel'),
          quickActions: !!document.querySelector('.quick-actions')
        };
      });
      
      const missingElements = Object.entries(gameElements)
        .filter(([key, present]) => !present)
        .map(([key]) => key);
      
      if (missingElements.length === 0) {
        this.log('All game UI elements present', 'success');
        return true;
      } else {
        this.log(`Missing UI elements: ${missingElements.join(', ')}`, 'error');
        return false;
      }
    } catch (error) {
      this.log(`Game navigation test failed: ${error.message}`, 'error');
      return false;
    }
  }

  async testAdventureFlow() {
    this.log('Testing adventure flow...', 'info');
    
    try {
      // Wait for game to initialize
      await page.waitForTimeout(2000);
      
      const initialState = await this.getGameState();
      this.log(`Initial game state - Energy: ${initialState?.energy}, Happiness: ${initialState?.happiness}`, 'info');
      
      // Look for Begin Adventure button
      const beginButton = await page.$('#start-adventure-btn');
      if (beginButton) {
        this.log('Clicking Begin Adventure...', 'info');
        await page.click('#start-adventure-btn');
        await page.waitForTimeout(2000);
        
        await this.takeScreenshot('05-adventure-started', 'Adventure scenario loaded');
        
        // Look for choice buttons
        const choiceButtons = await page.$$('.choice-button');
        if (choiceButtons.length > 0) {
          this.log(`Found ${choiceButtons.length} choice buttons`, 'success');
          
          // Click the first choice
          this.log('Making adventure choice...', 'info');
          await choiceButtons[0].click();
          await page.waitForTimeout(2000);
          
          await this.takeScreenshot('06-choice-made', 'Adventure choice made');
          
          const afterChoiceState = await this.getGameState();
          this.log(`After choice - Energy: ${afterChoiceState?.energy}, Happiness: ${afterChoiceState?.happiness}`, 'info');
          
          return true;
        } else {
          this.log('No choice buttons found in adventure', 'error');
          return false;
        }
      } else {
        this.log('Begin Adventure button not found', 'error');
        return false;
      }
    } catch (error) {
      this.log(`Adventure flow test failed: ${error.message}`, 'error');
      return false;
    }
  }

  async testQuickActions() {
    this.log('Testing quick actions...', 'info');
    
    try {
      const stateBefore = await this.getGameState();
      
      // Test Feed action
      const feedButton = await page.$('#feed-frog');
      if (feedButton) {
        this.log('Testing Feed action...', 'info');
        await page.click('#feed-frog');
        await page.waitForTimeout(1000);
        
        const stateAfterFeed = await this.getGameState();
        if (stateAfterFeed.energy > stateBefore.energy) {
          this.log(`Feed successful - Energy: ${stateBefore.energy} → ${stateAfterFeed.energy}`, 'success');
        }
        
        await this.takeScreenshot('07-after-feed', 'After feeding frog');
      }
      
      // Test Play action
      const playButton = await page.$('#play-frog');
      if (playButton) {
        this.log('Testing Play action...', 'info');
        await page.click('#play-frog');
        await page.waitForTimeout(1000);
        
        const stateAfterPlay = await this.getGameState();
        this.log(`Play action - Happiness: ${stateAfterPlay.happiness}`, 'info');
        
        await this.takeScreenshot('08-after-play', 'After playing with frog');
      }
      
      // Test Rest action
      const restButton = await page.$('#rest-frog');
      if (restButton) {
        this.log('Testing Rest action...', 'info');
        await page.click('#rest-frog');
        await page.waitForTimeout(1000);
        
        const stateAfterRest = await this.getGameState();
        this.log(`Rest action - Energy: ${stateAfterRest.energy}`, 'info');
        
        await this.takeScreenshot('09-after-rest', 'After resting frog');
      }
      
      return true;
    } catch (error) {
      this.log(`Quick actions test failed: ${error.message}`, 'error');
      return false;
    }
  }

  async testMultipleAdventures() {
    this.log('Testing multiple adventures...', 'info');
    
    try {
      let adventureCount = 0;
      const maxAdventures = 3;
      
      while (adventureCount < maxAdventures) {
        const currentState = await this.getGameState();
        
        if (currentState.energy < 20) {
          this.log('Energy too low, feeding frog...', 'info');
          await page.click('#feed-frog');
          await page.waitForTimeout(1000);
        }
        
        // Look for adventure button (could be "Begin Adventure" or "Continue Adventure")
        const adventureButton = await page.$('#start-adventure-btn') || 
                              await page.$('.choice-button.primary');
        
        if (adventureButton) {
          this.log(`Starting adventure ${adventureCount + 1}...`, 'info');
          await adventureButton.click();
          await page.waitForTimeout(2000);
          
          // Make a choice if available
          const choiceButtons = await page.$$('.choice-button:not(.primary)');
          if (choiceButtons.length > 0) {
            const randomChoice = Math.floor(Math.random() * choiceButtons.length);
            await choiceButtons[randomChoice].click();
            await page.waitForTimeout(2000);
            
            adventureCount++;
            this.log(`Adventure ${adventureCount} completed`, 'success');
            
            await this.takeScreenshot(`10-adventure-${adventureCount}`, `Adventure ${adventureCount} completed`);
          }
        } else {
          break;
        }
      }
      
      this.log(`Completed ${adventureCount} adventures`, 'success');
      return true;
    } catch (error) {
      this.log(`Multiple adventures test failed: ${error.message}`, 'error');
      return false;
    }
  }

  async generateTestReport() {
    const endTime = new Date();
    const duration = Math.round((endTime - this.startTime) / 1000);
    
    const report = {
      testRunId: this.startTime.getTime(),
      startTime: this.startTime.toISOString(),
      endTime: endTime.toISOString(),
      duration: `${duration} seconds`,
      totalTests: this.testResults.length,
      errors: this.testResults.filter(r => r.type === 'error').length,
      successes: this.testResults.filter(r => r.type === 'success').length,
      screenshots: this.screenshots.length,
      results: this.testResults,
      screenshotList: this.screenshots
    };
    
    this.log(`Test report generated: ${report.successes} successes, ${report.errors} errors`, 'info');
    return report;
  }
}

// Export for use in Playwright test
if (typeof module !== 'undefined' && module.exports) {
  module.exports = GameLoopTester;
}