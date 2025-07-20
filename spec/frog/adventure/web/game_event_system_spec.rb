# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Frog::Adventure::Web::GameEventSystem do
  let(:game_id) { "test_game_123" }
  let(:event_system) { described_class.new(game_id) }

  describe '#initialize' do
    it 'creates a new event system with the given game_id' do
      expect(event_system.game_id).to eq(game_id)
      expect(event_system.handlers).to be_empty
      expect(event_system.event_history).to be_empty
    end
  end

  describe '#register_handler' do
    it 'registers an event handler' do
      handler_called = false
      
      event_system.register_handler(:frog_tired) do |event|
        handler_called = true
        "handler result"
      end

      expect(event_system.has_handlers?(:frog_tired)).to be true
      
      event_system.trigger(:frog_tired, { test: true })
      expect(handler_called).to be true
    end

    it 'allows multiple handlers for the same event' do
      results = []
      
      event_system.register_handler(:frog_tired) { |event| results << "handler1" }
      event_system.register_handler(:frog_tired) { |event| results << "handler2" }

      event_system.trigger(:frog_tired, {})
      expect(results).to eq(["handler1", "handler2"])
    end

    it 'validates event types' do
      expect { event_system.register_handler(nil) { |event| } }.to raise_error(ArgumentError, /Event type cannot be nil/)
    end

    it 'requires a block' do
      expect { event_system.register_handler(:test) }.to raise_error(ArgumentError, /Handler block is required/)
    end
  end

  describe '#register_middleware' do
    it 'registers middleware that runs before all events' do
      middleware_called = false
      
      event_system.register_middleware do |event|
        middleware_called = true
        event[:middleware_ran] = true
      end

      event = event_system.trigger(:test_event, {})
      expect(middleware_called).to be true
      expect(event[:middleware_ran]).to be true
    end

    it 'continues processing even if middleware fails' do
      event_system.register_middleware { |event| raise "Middleware error" }
      
      handler_called = false
      event_system.register_handler(:test_event) { |event| handler_called = true }

      event = event_system.trigger(:test_event, {})
      expect(handler_called).to be true
      expect(event[:middleware_errors]).not_to be_nil
      expect(event[:middleware_errors]).not_to be_empty
    end
  end

  describe '#trigger' do
    it 'creates and processes an event' do
      event = event_system.trigger(:frog_happy, { happiness: 85 })
      
      expect(event[:type]).to eq('frog_happy')
      expect(event[:data][:happiness]).to eq(85)
      expect(event[:game_id]).to eq(game_id)
      expect(event[:triggered_at]).to be_a(Float)
      expect(event[:id]).to be_a(String)
    end

    it 'adds events to history' do
      expect(event_system.event_history.size).to eq(0)
      
      event_system.trigger(:test_event, {})
      expect(event_system.event_history.size).to eq(1)
      
      event_system.trigger(:another_event, {})
      expect(event_system.event_history.size).to eq(2)
    end

    it 'handles handler errors gracefully' do
      event_system.register_handler(:test_event) { |event| raise "Handler error" }
      
      event = event_system.trigger(:test_event, {})
      
      expect(event[:handler_results]).not_to be_nil
      expect(event[:handler_results]).not_to be_empty
      expect(event[:handler_results].first[:success]).to be false
      expect(event[:handler_results].first[:error]).to eq("Handler error")
    end

    it 'records successful handler results' do
      event_system.register_handler(:test_event) { |event| "success result" }
      
      event = event_system.trigger(:test_event, {})
      
      expect(event[:handler_results].first[:success]).to be true
      expect(event[:handler_results].first[:result]).to eq("success result")
    end
  end

  describe '#events_by_type' do
    it 'filters events by type' do
      event_system.trigger(:frog_tired, {})
      event_system.trigger(:frog_happy, {})
      event_system.trigger(:frog_tired, {})
      
      tired_events = event_system.events_by_type(:frog_tired)
      happy_events = event_system.events_by_type(:frog_happy)
      
      expect(tired_events.size).to eq(2)
      expect(happy_events.size).to eq(1)
    end
  end

  describe '#recent_events' do
    it 'returns the most recent events' do
      5.times { |i| event_system.trigger(:test_event, { index: i }) }
      
      recent = event_system.recent_events(3)
      expect(recent.size).to eq(3)
      expect(recent.last[:data][:index]).to eq(4) # Most recent
    end
  end

  describe '#clear_history' do
    it 'removes all events from history' do
      event_system.trigger(:test_event, {})
      expect(event_system.event_history.size).to eq(1)
      
      event_system.clear_history
      expect(event_system.event_history.size).to eq(0)
    end
  end

  describe '#stats' do
    it 'returns event system statistics' do
      event_system.register_handler(:test_event) { |event| }
      event_system.trigger(:test_event, {})
      event_system.trigger(:other_event, {})
      
      stats = event_system.stats
      expect(stats[:total_events]).to eq(2)
      expect(stats[:events_by_type]['test_event']).to eq(1)
      expect(stats[:events_by_type]['other_event']).to eq(1)
      expect(stats[:registered_handlers]['test_event']).to eq(1)
    end
  end

  describe '#clear_handlers' do
    it 'removes handlers for a specific event type' do
      event_system.register_handler(:test_event) { |event| }
      expect(event_system.has_handlers?(:test_event)).to be true
      
      event_system.clear_handlers(:test_event)
      expect(event_system.has_handlers?(:test_event)).to be_falsy
    end
  end

  describe 'helper methods' do
    describe '#trigger_turn_complete' do
      it 'triggers a turn completed event with correct data' do
        event = event_system.trigger_turn_complete(5, 3)
        
        expect(event[:type]).to eq('turn_completed')
        expect(event[:data][:turn_number]).to eq(5)
        expect(event[:data][:actions_processed]).to eq(3)
        expect(event[:data][:timestamp]).to be_a(Float)
      end
    end

    describe '#trigger_adventure_complete' do
      let(:adventure_data) { { scenario_id: 'forest_1', reward: { happiness: 10 } } }

      it 'triggers adventure completed event on success' do
        event = event_system.trigger_adventure_complete(adventure_data, success: true)
        expect(event[:type]).to eq('adventure_completed')
        expect(event[:data]).to eq(adventure_data)
      end

      it 'triggers adventure failed event on failure' do
        event = event_system.trigger_adventure_complete(adventure_data, success: false)
        expect(event[:type]).to eq('adventure_failed')
        expect(event[:data]).to eq(adventure_data)
      end
    end
  end

  describe 'event constants' do
    it 'defines all expected event types' do
      expect(described_class::EVENTS[:frog_level_up]).to eq('frog_level_up')
      expect(described_class::EVENTS[:adventure_completed]).to eq('adventure_completed')
      expect(described_class::EVENTS[:game_won]).to eq('game_won')
      expect(described_class::EVENTS[:random_encounter]).to eq('random_encounter')
    end
  end
end