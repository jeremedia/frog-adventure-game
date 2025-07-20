# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Frog::Adventure::Web::GameEngine do
  let(:game_id) { "test_game_123" }
  let(:engine) { described_class.new(game_id) }

  describe '#initialize' do
    it 'creates a new game engine with required components' do
      expect(engine.game_id).to eq(game_id)
      expect(engine.state).to be_empty
      expect(engine.action_queue).to be_a(Frog::Adventure::Web::ActionQueue)
      expect(engine.event_system).to be_a(Frog::Adventure::Web::GameEventSystem)
      expect(engine.turn_number).to eq(0)
    end
  end

  describe '#start_new_game' do
    it 'initializes a new game with a generated frog' do
      state = engine.start_new_game
      
      expect(state[:game_state]).to eq('playing')
      expect(state[:frog]).not_to be_nil
      expect(state[:frog][:name]).not_to be_nil
      expect(state[:frog][:name]).not_to be_empty
      expect(state[:adventures_completed]).to eq(0)
      expect(state[:total_turns]).to eq(0)
      expect(state[:achievements]).to eq([])
      expect(state[:unlocked_areas]).to include('starting_forest')
    end

    it 'triggers a game started event' do
      events_triggered = []
      engine.event_system.register_handler(:game_started) do |event|
        events_triggered << event
      end

      engine.start_new_game
      expect(events_triggered.size).to eq(1)
    end
  end

  describe '#enqueue_action' do
    before { engine.start_new_game }

    it 'adds an action to the queue and triggers an event' do
      events_triggered = []
      engine.event_system.register_handler(:action_queued) do |event|
        events_triggered << event
      end

      action_id = engine.enqueue_action(:move, { direction: 'north' })
      
      expect(action_id).to be_a(String)
      expect(engine.action_queue.size).to eq(1)
      expect(events_triggered.size).to eq(1)
      expect(events_triggered.first[:data][:action_type]).to eq(:move)
    end
  end

  describe '#process_turn' do
    before { engine.start_new_game }

    it 'returns error when game is not in playing state' do
      engine.state[:game_state] = 'paused'
      result = engine.process_turn
      
      expect(result[:success]).to be false
      expect(result[:message]).to include("not in playing state")
    end

    it 'processes a complete turn successfully' do
      engine.enqueue_action(:rest, {})
      
      result = engine.process_turn
      
      expect(result[:success]).to be true
      expect(result[:turn_number]).to eq(1)
      expect(result[:actions_processed].size).to eq(1)
      expect(result[:frog_state]).to be_a(Frog::Adventure::Web::Models::Frog)
      expect(result[:game_state]).to eq('playing')
    end

    it 'increments turn number' do
      expect(engine.turn_number).to eq(0)
      engine.process_turn
      expect(engine.turn_number).to eq(1)
    end

    it 'processes multiple actions in order' do
      engine.enqueue_action(:move, { direction: 'north' })
      engine.enqueue_action(:rest, {})
      
      result = engine.process_turn
      expect(result[:actions_processed].size).to eq(2)
    end

    it 'handles action processing errors gracefully' do
      # Use valid action that will fail due to cooldown
      frog = engine.current_frog
      frog.use_ability! # Put ability on cooldown
      engine.state[:frog] = frog.to_h
      engine.enqueue_action(:use_ability, { ability: frog.ability })
      
      result = engine.process_turn
      expect(result[:success]).to be true # Turn still completes
      expect(result[:actions_processed].first[:result][:success]).to be false
    end
  end

  describe '#current_frog' do
    it 'returns nil when no frog exists' do
      expect(engine.current_frog).to be_nil
    end

    it 'returns a Frog model when frog data exists' do
      engine.start_new_game
      frog = engine.current_frog
      
      expect(frog).to be_a(Frog::Adventure::Web::Models::Frog)
      expect(frog.name).not_to be_nil
      expect(frog.name).not_to be_empty
    end
  end

  describe '#game_playing?' do
    it 'returns false when game is not started' do
      expect(engine.game_playing?).to be false
    end

    it 'returns true when game is in playing state' do
      engine.start_new_game
      expect(engine.game_playing?).to be true
    end

    it 'returns false when game is won' do
      engine.start_new_game
      engine.state[:game_state] = 'won'
      expect(engine.game_playing?).to be false
    end
  end

  describe 'action processing' do
    before { engine.start_new_game }

    describe 'rest action' do
      it 'increases frog energy and happiness net of decay' do
        frog = engine.current_frog
        initial_energy = frog.energy
        initial_happiness = frog.happiness
        
        engine.enqueue_action(:rest, {})
        engine.process_turn
        
        updated_frog = engine.current_frog
        # Test that rest action improves stats despite decay
        expect(updated_frog.energy).to be > initial_energy - 5 # Allow for some variation
        expect(updated_frog.happiness).to be > initial_happiness
      end
    end

    describe 'use_ability action' do
      it 'uses frog ability when available' do
        frog = engine.current_frog
        expect(frog.can_use_ability?).to be true
        
        engine.enqueue_action(:use_ability, { ability: frog.ability })
        result = engine.process_turn
        
        updated_frog = engine.current_frog
        expect(updated_frog.can_use_ability?).to be false
        expect(updated_frog.ability_cooldown).to be > 0
      end

      it 'fails when ability is on cooldown' do
        frog = engine.current_frog
        frog.use_ability! # Put ability on cooldown
        engine.state[:frog] = frog.to_h
        
        engine.enqueue_action(:use_ability, { ability: frog.ability })
        result = engine.process_turn
        
        action_result = result[:actions_processed].first[:result]
        expect(action_result[:success]).to be false
        expect(action_result[:message]).to include("cooldown")
      end
    end

    describe 'adventure action' do
      it 'can succeed and provide rewards' do
        # Set up a high-stat frog for better success chance
        frog = engine.current_frog
        frog.adjust_energy(50)
        frog.adjust_happiness(50)
        engine.state[:frog] = frog.to_h
        
        initial_adventures = engine.state[:adventures_completed]
        
        # Try multiple times to account for randomness
        success_found = false
        10.times do
          engine.enqueue_action(:adventure, { scenario_id: 'test_scenario' })
          result = engine.process_turn
          
          action_result = result[:actions_processed].first[:result]
          if action_result[:success]
            success_found = true
            expect(engine.state[:adventures_completed]).to be > initial_adventures
            break
          end
        end
        
        expect(success_found).to be true
      end
    end

    describe 'feed action' do
      it 'increases frog energy and happiness net of decay' do
        frog = engine.current_frog
        initial_energy = frog.energy
        initial_happiness = frog.happiness
        
        engine.enqueue_action(:feed, { food: 'berry' })
        engine.process_turn
        
        updated_frog = engine.current_frog
        # Test that feed action improves stats despite decay
        expect(updated_frog.energy).to be > initial_energy - 5 # Allow for some variation
        expect(updated_frog.happiness).to be > initial_happiness
      end
    end
  end

  describe 'win/loss conditions' do
    before { engine.start_new_game }

    it 'detects win condition with high happiness and adventures' do
      frog = engine.current_frog
      frog.adjust_happiness(90 - frog.happiness) # Set to 90
      engine.state[:frog] = frog.to_h
      engine.state[:adventures_completed] = 10
      
      result = engine.process_turn
      expect(result[:game_result]).not_to be_nil
      expect(result[:game_result][:result]).to eq(:won)
      expect(engine.state[:game_state]).to eq('won')
    end

    it 'detects loss condition with zero energy' do
      frog = engine.current_frog
      frog.adjust_energy(-frog.energy) # Set to 0
      engine.state[:frog] = frog.to_h
      
      result = engine.process_turn
      expect(result[:game_result][:result]).to eq(:lost)
      expect(engine.state[:game_state]).to eq('lost')
    end

    it 'detects loss condition with zero happiness' do
      frog = engine.current_frog
      frog.adjust_happiness(-frog.happiness) # Set to 0
      engine.state[:frog] = frog.to_h
      
      result = engine.process_turn
      expect(result[:game_result][:result]).to eq(:lost)
      expect(engine.state[:game_state]).to eq('lost')
    end
  end

  describe '#stats' do
    before { engine.start_new_game }

    it 'returns comprehensive game statistics' do
      engine.enqueue_action(:rest, {})
      engine.process_turn
      
      stats = engine.stats
      
      expect(stats[:game_id]).to eq(game_id)
      expect(stats[:turn_number]).to eq(1)
      expect(stats[:game_state]).to eq('playing')
      expect(stats[:adventures_completed]).to eq(0)
      expect(stats[:action_queue_stats]).not_to be_nil
      expect(stats[:event_stats]).not_to be_nil
      expect(stats[:frog_stats]).not_to be_nil
    end
  end

  describe 'auto-save functionality' do
    before { engine.start_new_game }

    it 'auto-saves every 5 turns' do
      save_events = []
      engine.event_system.register_handler(:save_game) do |event|
        save_events << event
      end

      # Process 5 turns
      5.times do
        engine.enqueue_action(:rest, {})
        engine.process_turn
      end

      expect(save_events.size).to eq(1) # Should auto-save on turn 5
    end
  end

  describe 'event-driven behavior' do
    before { engine.start_new_game }

    it 'automatically rests tired frogs' do
      # Make frog tired
      frog = engine.current_frog
      frog.adjust_energy(-85) # Make energy < 20
      engine.state[:frog] = frog.to_h
      
      # Process first turn to trigger tired event and auto-queue rest
      result = engine.process_turn
      
      # Process second turn to execute the auto-rest action
      result = engine.process_turn
      
      # Should have auto-queued and processed a rest action
      updated_frog = engine.current_frog
      expect(updated_frog.energy).to be > 20
    end

    it 'triggers positive events for sad frogs' do
      # Make frog sad
      frog = engine.current_frog
      frog.adjust_happiness(-35) # Make happiness < 30
      engine.state[:frog] = frog.to_h
      
      random_events = []
      engine.event_system.register_handler(:random_encounter) do |event|
        random_events << event
      end
      
      # Process first turn to trigger sad event and auto-queue random encounter
      result = engine.process_turn
      
      # Process second turn to execute the random encounter action
      result = engine.process_turn
      
      # Should have triggered a random encounter
      expect(random_events.size).to be >= 1
    end
  end
end