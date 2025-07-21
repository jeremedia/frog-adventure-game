#!/usr/bin/env ruby
# frozen_string_literal: true

# LLM Integration Test Suite
# Tests that Ollama LLM is properly integrated and generating dynamic content

require 'net/http'
require 'json'
require 'set'

# Add colorize methods if not available
class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end
  
  def red; colorize(31); end
  def green; colorize(32); end
  def yellow; colorize(33); end
  def blue; colorize(34); end
  def cyan; colorize(36); end
  def bold; "\e[1m#{self}\e[22m"; end
end

class LLMIntegrationTester
  API_BASE = 'http://localhost:4567'
  OLLAMA_BASE = 'http://localhost:11434'
  
  def initialize
    @results = []
    @unique_frogs = Set.new
    @unique_scenarios = Set.new
    @unique_outcomes = Set.new
    @start_time = Time.now
  end

  def run_all_tests
    puts "\n🧪 Starting LLM Integration Tests".cyan.bold
    puts "=" * 60
    
    # Test 1: Verify Ollama is running
    test_ollama_connection
    
    # Test 2: Test direct Ollama model
    test_ollama_model
    
    # Test 3: Test frog generation uniqueness
    test_frog_generation_uniqueness
    
    # Test 4: Test adventure scenario uniqueness
    test_adventure_scenario_uniqueness
    
    # Test 5: Test choice outcome contextuality
    test_choice_outcome_context
    
    # Test 6: Performance test
    test_response_times
    
    # Test 7: Verify no hardcoded content
    test_no_hardcoded_content
    
    # Summary
    print_summary
  end
  
  private
  
  def test_ollama_connection
    print "Testing Ollama connection... "
    
    begin
      uri = URI("#{OLLAMA_BASE}/api/tags")
      response = Net::HTTP.get_response(uri)
      
      if response.code == '200'
        models = JSON.parse(response.body)['models'] || []
        gemma_model = models.find { |m| m['name'].include?('gemma3n') }
        
        if gemma_model
          log_success "Ollama running with gemma3n:e4b model"
        else
          log_failure "Ollama running but gemma3n model not found"
        end
      else
        log_failure "Ollama not responding (#{response.code})"
      end
    rescue => e
      log_failure "Cannot connect to Ollama: #{e.message}"
    end
  end
  
  def test_ollama_model
    print "Testing direct Ollama generation... "
    
    begin
      uri = URI("#{OLLAMA_BASE}/api/generate")
      request = Net::HTTP::Post.new(uri)
      request['Content-Type'] = 'application/json'
      request.body = {
        model: 'gemma3n:e4b',
        prompt: 'Generate a JSON object with a single field "test" containing "success"',
        stream: false
      }.to_json
      
      response = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(request)
      end
      
      if response.code == '200'
        result = JSON.parse(response.body)
        log_success "Ollama model responding correctly"
      else
        log_failure "Ollama model error: #{response.code}"
      end
    rescue => e
      log_failure "Ollama model test failed: #{e.message}"
    end
  end
  
  def test_frog_generation_uniqueness
    puts "\n📊 Testing Frog Generation Uniqueness (10 frogs)".yellow
    
    10.times do |i|
      print "  Generating frog #{i + 1}... "
      
      begin
        response = api_post('/api/frog/generate', {})
        
        if response[:success]
          frog = response[:data]['frog']
          frog_signature = "#{frog['name']}-#{frog['ability']}-#{frog['description']}"
          
          if @unique_frogs.include?(frog_signature)
            log_warning "Duplicate frog detected!"
          else
            @unique_frogs.add(frog_signature)
            log_success "Unique: #{frog['name']} (#{frog['ability']})"
          end
          
          # Check if response looks like LLM-generated
          if frog['backstory'] && frog['backstory'].length > 50
            @results << { test: 'frog_llm_check', passed: true }
          else
            @results << { test: 'frog_llm_check', passed: false, note: 'Backstory too short' }
          end
        else
          log_failure "API error"
        end
      rescue => e
        log_failure "Error: #{e.message}"
      end
      
      sleep(0.5) # Avoid overwhelming the API
    end
    
    uniqueness_percent = (@unique_frogs.size / 10.0 * 100).round
    puts "  ✨ Uniqueness: #{uniqueness_percent}% (#{@unique_frogs.size}/10 unique)".green
  end
  
  def test_adventure_scenario_uniqueness
    puts "\n📊 Testing Adventure Scenario Uniqueness (10 scenarios)".yellow
    
    10.times do |i|
      print "  Generating scenario #{i + 1}... "
      
      begin
        response = api_post('/api/adventure/start', {
          frog_id: 'test',
          frog_stats: {
            strength: rand(5..20),
            agility: rand(5..20),
            intelligence: rand(5..20),
            magic: rand(5..20),
            luck: rand(5..20)
          }
        })
        
        if response[:success]
          scenario = response[:data]['scenario']
          scenario_signature = "#{scenario['title']}-#{scenario['description']}"
          
          if @unique_scenarios.include?(scenario_signature)
            log_warning "Duplicate scenario detected!"
          else
            @unique_scenarios.add(scenario_signature)
            log_success "Unique: #{scenario['title']}"
          end
          
          # Check if description is LLM-quality
          if scenario['description'].length > 100 && scenario['choices'].size >= 3
            @results << { test: 'scenario_llm_check', passed: true }
          else
            @results << { test: 'scenario_llm_check', passed: false }
          end
        else
          log_failure "API error"
        end
      rescue => e
        log_failure "Error: #{e.message}"
      end
      
      sleep(0.5)
    end
    
    uniqueness_percent = (@unique_scenarios.size / 10.0 * 100).round
    puts "  ✨ Uniqueness: #{uniqueness_percent}% (#{@unique_scenarios.size}/10 unique)".green
  end
  
  def test_choice_outcome_context
    puts "\n📊 Testing Choice Outcome Contextuality".yellow
    
    # Test with different stat configurations
    stat_configs = [
      { name: 'Strong Frog', stats: { strength: 20, agility: 5, intelligence: 5, magic: 5, luck: 5 } },
      { name: 'Smart Frog', stats: { strength: 5, agility: 5, intelligence: 20, magic: 5, luck: 5 } },
      { name: 'Lucky Frog', stats: { strength: 5, agility: 5, intelligence: 5, magic: 5, luck: 20 } }
    ]
    
    stat_configs.each do |config|
      print "  Testing #{config[:name]}... "
      
      begin
        response = api_post('/api/adventure/choice', {
          scenario_id: 'test',
          choice: { id: 1, text: 'Jump across the chasm', risk: 'high' },
          frog_stats: config[:stats]
        })
        
        if response[:success]
          outcome = response[:data]['outcome']
          
          # Check if outcome references the relevant stat
          message = outcome['message'].downcase
          if (config[:name].include?('Strong') && message.include?('strength')) ||
             (config[:name].include?('Smart') && message.include?('intelligen')) ||
             (config[:name].include?('Lucky') && message.include?('luck'))
            log_success "Context-aware outcome detected"
            @results << { test: 'outcome_context', passed: true }
          else
            log_warning "Outcome may not be context-aware"
            @results << { test: 'outcome_context', passed: false }
          end
          
          @unique_outcomes.add(outcome['message'])
        else
          log_failure "API error"
        end
      rescue => e
        log_failure "Error: #{e.message}"
      end
      
      sleep(0.5)
    end
  end
  
  def test_response_times
    puts "\n⏱️  Testing Response Times".yellow
    
    times = {
      frog_generation: [],
      adventure_start: [],
      choice_processing: []
    }
    
    3.times do |i|
      # Test frog generation time
      start = Time.now
      api_post('/api/frog/generate', {})
      times[:frog_generation] << Time.now - start
      
      # Test adventure start time
      start = Time.now
      api_post('/api/adventure/start', { frog_id: 'test' })
      times[:adventure_start] << Time.now - start
      
      # Test choice processing time
      start = Time.now
      api_post('/api/adventure/choice', { 
        scenario_id: 'test',
        choice: { id: 1, risk: 'medium' }
      })
      times[:choice_processing] << Time.now - start
      
      sleep(0.2)
    end
    
    times.each do |endpoint, measurements|
      avg_time = (measurements.sum / measurements.size).round(2)
      if avg_time < 3.0
        puts "  ✅ #{endpoint}: #{avg_time}s average".green
        @results << { test: "performance_#{endpoint}", passed: true, time: avg_time }
      else
        puts "  ⚠️  #{endpoint}: #{avg_time}s average (>3s)".yellow
        @results << { test: "performance_#{endpoint}", passed: false, time: avg_time }
      end
    end
  end
  
  def test_no_hardcoded_content
    puts "\n🔍 Checking for Hardcoded Content".yellow
    
    # Known hardcoded values to check for
    hardcoded_frogs = ['Sparky', 'Bubbles', 'Rocky', 'Whisper', 'Prism', 'Sage']
    hardcoded_scenarios = ['The Mysterious Pond', 'The Singing Stream', 'The Ancient Lily Pad']
    
    found_hardcoded = false
    
    # Check generated frogs
    print "  Checking frog names... "
    frog_names = @unique_frogs.map { |f| f.split('-').first }
    hardcoded_found = frog_names & hardcoded_frogs
    if hardcoded_found.empty?
      log_success "No hardcoded frog names found"
    else
      log_warning "Found hardcoded names: #{hardcoded_found.join(', ')}"
      found_hardcoded = true
    end
    
    # Check scenarios
    print "  Checking scenario titles... "
    scenario_titles = @unique_scenarios.map { |s| s.split('-').first }
    hardcoded_found = scenario_titles & hardcoded_scenarios
    if hardcoded_found.empty?
      log_success "No hardcoded scenarios found"
    else
      log_warning "Found hardcoded scenarios: #{hardcoded_found.join(', ')}"
      found_hardcoded = true
    end
    
    @results << { test: 'no_hardcoded_content', passed: !found_hardcoded }
  end
  
  def print_summary
    puts "\n" + "=" * 60
    puts "📊 LLM Integration Test Summary".cyan.bold
    puts "=" * 60
    
    total_tests = @results.size
    passed_tests = @results.count { |r| r[:passed] }
    failed_tests = total_tests - passed_tests
    
    puts "Total Tests: #{total_tests}"
    puts "Passed: #{passed_tests}".green
    puts "Failed: #{failed_tests}".red if failed_tests > 0
    puts "Warnings: #{failed_tests}".yellow if failed_tests > 0
    
    puts "\n📈 Content Uniqueness:"
    puts "  Unique Frogs: #{@unique_frogs.size}"
    puts "  Unique Scenarios: #{@unique_scenarios.size}"
    puts "  Unique Outcomes: #{@unique_outcomes.size}"
    
    duration = Time.now - @start_time
    puts "\n⏱️  Total Test Duration: #{duration.round(2)}s"
    
    if failed_tests == 0 && @unique_frogs.size >= 8 && @unique_scenarios.size >= 8
      puts "\n✅ LLM Integration is working correctly!".green.bold
      puts "The game is generating unique, dynamic content.".green
    else
      puts "\n⚠️  LLM Integration needs attention".yellow.bold
      puts "The game may be using fallback content.".yellow
    end
  end
  
  def api_post(endpoint, data)
    uri = URI("#{API_BASE}#{endpoint}")
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = data.to_json
    
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(request)
    end
    
    if response.code == '200'
      { success: true, data: JSON.parse(response.body) }
    else
      { success: false, code: response.code, body: response.body }
    end
  rescue => e
    { success: false, error: e.message }
  end
  
  def log_success(message)
    puts "✅ #{message}".green
    @results << { test: caller_locations(1,1)[0].label, passed: true }
  end
  
  def log_failure(message)
    puts "❌ #{message}".red
    @results << { test: caller_locations(1,1)[0].label, passed: false, error: message }
  end
  
  def log_warning(message)
    puts "⚠️  #{message}".yellow
  end
end

# Run the tests
if __FILE__ == $0
  tester = LLMIntegrationTester.new
  tester.run_all_tests
end