#!/usr/bin/env node

/**
 * Playwright Game Loop Test Runner
 * 
 * This script runs the complete game test using Playwright automation.
 * It can be run from the command line to test the entire game flow.
 */

const fs = require('fs');
const path = require('path');

// Ensure test-screenshots directory exists
const screenshotDir = path.join(__dirname, 'test-screenshots');
if (!fs.existsSync(screenshotDir)) {
  fs.mkdirSync(screenshotDir, { recursive: true });
}

async function runGameTest() {
  console.log('🎮 Starting Frog Adventure Game Loop Test...');
  console.log('=' .repeat(50));
  
  let browser, page;
  
  try {
    // Import Playwright (will be installed when test runs)
    const { chromium } = require('playwright');
    
    // Launch browser
    browser = await chromium.launch({ 
      headless: false,  // Show browser for debugging
      slowMo: 500       // Slow down actions for visibility
    });
    
    const context = await browser.newContext({
      viewport: { width: 1280, height: 720 }
    });
    
    page = await context.newPage();
    
    // Load the game tester
    const GameLoopTester = require('./game-loop-test.js');
    const tester = new GameLoopTester();
    
    // Make page available globally for screenshots
    global.page = page;
    
    // Add screenshot helper to page context
    await page.addInitScript(() => {
      window.testHelper = {
        takeScreenshot: async (name, description) => {
          // This will be called from the test context
          console.log(`📸 Screenshot: ${name} - ${description}`);
        }
      };
    });
    
    console.log('🌐 Browser launched, starting tests...\n');
    
    // Run test sequence
    const results = [];
    
    // Test 1: Frog Generation
    console.log('🐸 Test 1: Frog Generation');
    const frogGenResult = await runTestStep(tester.testFrogGeneration.bind(tester));
    results.push({ test: 'Frog Generation', passed: frogGenResult });
    
    if (!frogGenResult) {
      console.log('❌ Frog generation failed, stopping tests');
      return;
    }
    
    // Test 2: Game Navigation
    console.log('\n🎯 Test 2: Game Navigation');
    const navResult = await runTestStep(tester.testGameNavigation.bind(tester));
    results.push({ test: 'Game Navigation', passed: navResult });
    
    if (!navResult) {
      console.log('❌ Game navigation failed, stopping tests');
      return;
    }
    
    // Test 3: Adventure Flow
    console.log('\n⚔️ Test 3: Adventure Flow');
    const adventureResult = await runTestStep(tester.testAdventureFlow.bind(tester));
    results.push({ test: 'Adventure Flow', passed: adventureResult });
    
    // Test 4: Quick Actions
    console.log('\n⚡ Test 4: Quick Actions');
    const actionsResult = await runTestStep(tester.testQuickActions.bind(tester));
    results.push({ test: 'Quick Actions', passed: actionsResult });
    
    // Test 5: Multiple Adventures
    console.log('\n🔄 Test 5: Multiple Adventures');
    const multipleResult = await runTestStep(tester.testMultipleAdventures.bind(tester));
    results.push({ test: 'Multiple Adventures', passed: multipleResult });
    
    // Generate final report
    console.log('\n📊 Generating test report...');
    const report = await tester.generateTestReport();
    
    // Save report to file
    const reportPath = path.join(__dirname, `test-report-${Date.now()}.json`);
    fs.writeFileSync(reportPath, JSON.stringify(report, null, 2));
    
    // Print summary
    console.log('\n' + '=' .repeat(50));
    console.log('📈 TEST SUMMARY');
    console.log('=' .repeat(50));
    
    results.forEach(result => {
      const status = result.passed ? '✅' : '❌';
      console.log(`${status} ${result.test}`);
    });
    
    const passedTests = results.filter(r => r.passed).length;
    const totalTests = results.length;
    
    console.log(`\n📊 Results: ${passedTests}/${totalTests} tests passed`);
    console.log(`⏱️ Duration: ${report.duration}`);
    console.log(`📸 Screenshots: ${report.screenshots.length}`);
    console.log(`📄 Report saved: ${reportPath}`);
    
    if (passedTests === totalTests) {
      console.log('\n🎉 All tests passed! Game is working correctly.');
    } else {
      console.log('\n⚠️ Some tests failed. Check the report for details.');
    }
    
  } catch (error) {
    console.error('💥 Test runner error:', error);
  } finally {
    if (browser) {
      console.log('\n🔚 Closing browser...');
      await browser.close();
    }
  }
}

async function runTestStep(testFunction) {
  try {
    const result = await testFunction();
    return result;
  } catch (error) {
    console.error(`Test step failed: ${error.message}`);
    return false;
  }
}

// Run if called directly
if (require.main === module) {
  runGameTest().catch(console.error);
}

module.exports = { runGameTest };