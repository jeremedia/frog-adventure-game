# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Frog::Adventure::Web::Models::Events::ChoiceEvent do
  let(:scenario) { "a mysterious pond" }
  let(:choice) { "dive in" }
  let(:outcome) { { success: true, message: "Found a shiny pebble!" } }
  let(:consequences) { { item_gained: "Shiny Pebble", happiness_change: 5 } }
  let(:frog_state) { { name: "Hoppy", energy: 75, happiness: 60 } }
  
  describe '#initialize' do
    it 'creates a choice event with required parameters' do
      event = described_class.new(
        scenario: scenario,
        choice: choice,
        outcome: outcome
      )
      
      expect(event.type).to eq('choice')
      expect(event.scenario).to eq(scenario)
      expect(event.choice).to eq(choice)
      expect(event.outcome).to eq(outcome)
      expect(event.consequences).to eq({})
    end
    
    it 'accepts optional consequences and frog state' do
      event = described_class.new(
        scenario: scenario,
        choice: choice,
        outcome: outcome,
        consequences: consequences,
        frog_state: frog_state
      )
      
      expect(event.consequences).to eq(consequences)
      expect(event.frog_state).to eq(frog_state)
    end
  end
  
  describe '#narrative_description' do
    context 'with successful outcome' do
      let(:event) do
        described_class.new(
          scenario: scenario,
          choice: choice,
          outcome: outcome
        )
      end
      
      it 'generates a narrative description' do
        narrative = event.to_narrative
        expect(narrative[:description]).to eq(
          "Faced with a mysterious pond, chose to dive in. The attempt succeeded. Found a shiny pebble!"
        )
      end
    end
    
    context 'with failed outcome' do
      let(:failed_outcome) { { success: false, message: "The water was too cold!" } }
      let(:event) do
        described_class.new(
          scenario: scenario,
          choice: "jump over it",
          outcome: failed_outcome
        )
      end
      
      it 'generates a narrative description for failure' do
        narrative = event.to_narrative
        expect(narrative[:description]).to eq(
          "Faced with a mysterious pond, chose to jump over it. The attempt failed. The water was too cold!"
        )
      end
    end
  end
  
  describe '#extract_visual_elements' do
    context 'with item gained' do
      let(:event) do
        described_class.new(
          scenario: scenario,
          choice: choice,
          outcome: outcome,
          consequences: { item_gained: "Magic Lily Pad" }
        )
      end
      
      it 'includes visual elements for items' do
        narrative = event.to_narrative
        visual_elements = narrative[:visual_elements]
        
        expect(visual_elements).to include(
          { type: :setting, description: scenario },
          { type: :action, description: choice },
          { type: :item, description: "Magic Lily Pad" }
        )
      end
    end
    
    context 'with location unlocked' do
      let(:event) do
        described_class.new(
          scenario: "ancient gate",
          choice: "solve the riddle",
          outcome: { success: true },
          consequences: { location_unlocked: "Hidden Grove" }
        )
      end
      
      it 'includes visual elements for new locations' do
        narrative = event.to_narrative
        visual_elements = narrative[:visual_elements]
        
        expect(visual_elements).to include(
          { type: :location, description: "Hidden Grove" }
        )
      end
    end
  end
  
  describe 'importance determination' do
    it 'inherits importance from base class logic' do
      normal_event = described_class.new(
        scenario: scenario,
        choice: choice,
        outcome: outcome,
        importance: :normal
      )
      
      critical_event = described_class.new(
        scenario: "final challenge",
        choice: "face the boss",
        outcome: { success: true },
        importance: :critical
      )
      
      expect(normal_event.narrative_worthy?).to be true
      expect(critical_event.cinematic?).to be true
    end
  end
end