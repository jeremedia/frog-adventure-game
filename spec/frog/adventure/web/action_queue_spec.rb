# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Frog::Adventure::Web::ActionQueue do
  let(:game_id) { "test_game_123" }
  let(:queue) { described_class.new(game_id) }

  describe '#initialize' do
    it 'creates a new queue with the given game_id' do
      expect(queue.game_id).to eq(game_id)
      expect(queue.actions).to be_empty
    end
  end

  describe '#enqueue' do
    it 'adds an action to the queue' do
      action_id = queue.enqueue(:move, { direction: 'north' })
      
      expect(action_id).to be_a(String)
      expect(queue.size).to eq(1)
      expect(queue.actions.first[:type]).to eq('move')
      expect(queue.actions.first[:params][:direction]).to eq('north')
    end

    it 'handles priority correctly' do
      queue.enqueue(:move, { direction: 'north' }, priority: :normal)
      queue.enqueue(:use_ability, { ability: 'jump' }, priority: :high)
      queue.enqueue(:rest, {}, priority: :low)

      # High priority should be first
      expect(queue.actions[0][:priority]).to eq(:high)
      expect(queue.actions[1][:priority]).to eq(:normal)
      expect(queue.actions[2][:priority]).to eq(:low)
    end

    it 'validates action types' do
      expect { queue.enqueue(nil, {}) }.to raise_error(ArgumentError, /Action type cannot be nil/)
      expect { queue.enqueue(:move, "not a hash") }.to raise_error(ArgumentError, /Params must be a hash/)
    end

    it 'validates specific action parameters' do
      expect { queue.enqueue(:move, {}) }.to raise_error(ArgumentError, /Move action requires direction/)
      expect { queue.enqueue(:use_ability, {}) }.to raise_error(ArgumentError, /Use ability action requires ability name/)
      expect { queue.enqueue(:feed, {}) }.to raise_error(ArgumentError, /Feed action requires food item/)
    end
  end

  describe '#process_next' do
    it 'processes the next action in the queue' do
      queue.enqueue(:rest, {})
      
      processed_action = queue.process_next do |action|
        { success: true, message: "Processed #{action[:type]}" }
      end

      expect(processed_action[:status]).to eq(:completed)
      expect(processed_action[:result][:success]).to be true
      expect(queue.size).to eq(0)
    end

    it 'handles action processing errors' do
      queue.enqueue(:rest, {})
      
      processed_action = queue.process_next do |action|
        raise StandardError, "Test error"
      end

      expect(processed_action[:status]).to eq(:failed)
      expect(processed_action[:error]).to eq("Test error")
    end

    it 'returns nil when queue is empty' do
      result = queue.process_next { |action| "test" }
      expect(result).to be_nil
    end
  end

  describe '#clear' do
    it 'removes all actions from the queue' do
      queue.enqueue(:move, { direction: 'north' })
      queue.enqueue(:rest, {})
      
      expect(queue.size).to eq(2)
      queue.clear
      expect(queue.size).to eq(0)
    end
  end

  describe '#pending_actions' do
    it 'returns only pending actions' do
      queue.enqueue(:move, { direction: 'north' })
      queue.enqueue(:rest, {})
      
      expect(queue.pending_actions.size).to eq(2)
      
      queue.process_next { |action| { success: true } }
      expect(queue.pending_actions.size).to eq(1)
    end
  end

  describe '#stats' do
    it 'returns queue statistics' do
      queue.enqueue(:move, { direction: 'north' }, priority: :high)
      queue.enqueue(:rest, {}, priority: :normal)
      
      stats = queue.stats
      expect(stats[:total]).to eq(2)
      expect(stats[:pending]).to eq(2)
      expect(stats[:by_priority][:high]).to eq(1)
      expect(stats[:by_priority][:normal]).to eq(1)
    end
  end

  describe '#to_json and .from_json' do
    it 'serializes and deserializes the queue correctly' do
      queue.enqueue(:move, { direction: 'north' })
      queue.enqueue(:rest, {})
      
      json_string = queue.to_json
      restored_queue = described_class.from_json(json_string)
      
      expect(restored_queue.game_id).to eq(game_id)
      expect(restored_queue.size).to eq(2)
      expect(restored_queue.actions.first[:type]).to eq('move')
    end
  end

  describe 'action type validation' do
    it 'accepts valid action types' do
      expect { queue.enqueue(:move, { direction: 'north' }) }.not_to raise_error
      expect { queue.enqueue(:use_ability, { ability: 'jump' }) }.not_to raise_error
      expect { queue.enqueue(:rest, {}) }.not_to raise_error
      expect { queue.enqueue(:feed, { food: 'berry' }) }.not_to raise_error
      expect { queue.enqueue(:interact, { target: 'lily_pad' }) }.not_to raise_error
      expect { queue.enqueue(:adventure, { scenario_id: 'forest_1' }) }.not_to raise_error
    end
  end
end