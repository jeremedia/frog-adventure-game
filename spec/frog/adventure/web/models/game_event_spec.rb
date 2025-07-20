# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Frog::Adventure::Web::Models::GameEvent do
  let(:event_type) { :test_event }
  let(:data) { { test: "data" } }
  let(:frog_state) { { name: "Hoppy", energy: 75, happiness: 60 } }
  
  describe '#initialize' do
    it 'creates a new event with required attributes' do
      event = described_class.new(type: event_type, data: data)
      
      expect(event.type).to eq('test_event')
      expect(event.data).to eq(data)
      expect(event.importance).to eq(:normal)
      expect(event.id).to be_a(String)
      expect(event.timestamp).to be_a(Float)
    end
    
    it 'accepts optional parameters' do
      event = described_class.new(
        type: event_type,
        data: data,
        importance: :high,
        frog_state: frog_state,
        metadata: { source: "test" }
      )
      
      expect(event.importance).to eq(:high)
      expect(event.frog_state).to eq(frog_state)
      expect(event.metadata).to eq({ source: "test" })
    end
    
    it 'validates event type' do
      expect { described_class.new(type: nil) }.to raise_error(ArgumentError, /Event type cannot be empty/)
      expect { described_class.new(type: "") }.to raise_error(ArgumentError, /Event type cannot be empty/)
    end
    
    it 'validates importance level' do
      expect { described_class.new(type: event_type, importance: :invalid) }.to raise_error(ArgumentError, /Invalid importance level/)
    end
  end
  
  describe '#to_narrative' do
    let(:event) { described_class.new(type: event_type, data: data, frog_state: frog_state) }
    
    it 'returns narrative-friendly format' do
      narrative = event.to_narrative
      
      expect(narrative).to include(
        id: event.id,
        timestamp: event.timestamp,
        type: 'test_event',
        description: "test_event occurred",
        importance: :normal,
        emotional_context: be_a(Hash),
        visual_elements: []
      )
    end
    
    it 'includes emotional context from frog state' do
      narrative = event.to_narrative
      emotional_context = narrative[:emotional_context]
      
      expect(emotional_context).to include(
        energy_level: "energetic",
        mood: "content",  # 60 happiness = content
        condition: "normal"
      )
    end
  end
  
  describe '#narrative_worthy?' do
    it 'returns true for normal and higher importance' do
      expect(described_class.new(type: event_type, importance: :low).narrative_worthy?).to be false
      expect(described_class.new(type: event_type, importance: :normal).narrative_worthy?).to be true
      expect(described_class.new(type: event_type, importance: :high).narrative_worthy?).to be true
      expect(described_class.new(type: event_type, importance: :critical).narrative_worthy?).to be true
    end
  end
  
  describe '#cinematic?' do
    it 'returns true for high and critical importance' do
      expect(described_class.new(type: event_type, importance: :low).cinematic?).to be false
      expect(described_class.new(type: event_type, importance: :normal).cinematic?).to be false
      expect(described_class.new(type: event_type, importance: :high).cinematic?).to be true
      expect(described_class.new(type: event_type, importance: :critical).cinematic?).to be true
    end
  end
  
  describe '#to_h and #to_json' do
    let(:event) { described_class.new(type: event_type, data: data, frog_state: frog_state) }
    
    it 'converts to hash with all attributes' do
      hash = event.to_h
      
      expect(hash).to include(
        id: event.id,
        timestamp: event.timestamp,
        type: 'test_event',
        data: data,
        importance: :normal,
        frog_state: frog_state,
        metadata: {}
      )
    end
    
    it 'converts to JSON' do
      json = event.to_json
      parsed = JSON.parse(json, symbolize_names: true)
      
      expect(parsed[:type]).to eq('test_event')
      expect(parsed[:data]).to eq(data)
    end
  end
  
  describe 'energy and mood descriptors' do
    it 'correctly describes energy levels' do
      low_energy = described_class.new(type: event_type, frog_state: { energy: 10, happiness: 50 })
      high_energy = described_class.new(type: event_type, frog_state: { energy: 90, happiness: 50 })
      
      expect(low_energy.to_narrative[:emotional_context][:energy_level]).to eq("exhausted")
      expect(high_energy.to_narrative[:emotional_context][:energy_level]).to eq("vibrant")
    end
    
    it 'correctly describes mood levels' do
      sad_frog = described_class.new(type: event_type, frog_state: { energy: 50, happiness: 10 })
      happy_frog = described_class.new(type: event_type, frog_state: { energy: 50, happiness: 90 })
      
      expect(sad_frog.to_narrative[:emotional_context][:mood]).to eq("depressed")
      expect(happy_frog.to_narrative[:emotional_context][:mood]).to eq("ecstatic")
    end
  end
end