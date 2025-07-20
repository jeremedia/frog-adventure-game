# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Frog::Adventure::Web::AdventureLog do
  let(:session_id) { "test_session_123" }
  let(:log) { described_class.new(session_id) }
  
  describe '#initialize' do
    it 'creates a new adventure log with the given session ID' do
      expect(log.session_id).to eq(session_id)
      expect(log.events).to be_empty
      expect(log.key_moments).to be_empty
      expect(log.relationships).to be_empty
      expect(log.story_arcs).to be_empty
    end
  end
  
  describe '#log_choice' do
    let(:scenario) { "mysterious crossroads" }
    let(:choice) { "take the left path" }
    let(:outcome) { { success: true, message: "Found a peaceful meadow" } }
    let(:consequences) { { location_unlocked: "Peaceful Meadow" } }
    
    it 'logs a choice event' do
      log.log_choice(scenario, choice, outcome, consequences)
      
      expect(log.events.size).to eq(1)
      event = log.events.first
      expect(event).to be_a(Frog::Adventure::Web::Models::Events::ChoiceEvent)
      expect(event.scenario).to eq(scenario)
      expect(event.choice).to eq(choice)
    end
    
    it 'analyzes for story beats' do
      log.log_choice(scenario, choice, outcome, { starts_arc: true, arc_theme: "exploration" })
      
      expect(log.story_arcs.size).to eq(1)
      arc = log.story_arcs.first
      expect(arc[:theme]).to eq("exploration")
      expect(arc[:status]).to eq(:active)
    end
  end
  
  describe '#log_action' do
    it 'logs different types of actions' do
      log.log_action(:ability_used, "Super Jump", { success: true })
      log.log_action(:item_collected, "Magic Berry")
      log.log_action(:rest)
      
      expect(log.events.size).to eq(3)
      expect(log.events_by_type(:action).size).to eq(3)
    end
    
    it 'sets appropriate importance levels' do
      log.log_action(:ability_used, "Power Leap")
      log.log_action(:rest)
      
      ability_event = log.events.find { |e| e.data[:action_type] == :ability_used }
      rest_event = log.events.find { |e| e.data[:action_type] == :rest }
      
      expect(ability_event.importance).to eq(:normal)
      expect(rest_event.importance).to eq(:low)
    end
  end
  
  describe '#log_emotion' do
    it 'logs emotional events' do
      log.log_emotion(:happiness_boost, "finding a friend", :strong)
      
      expect(log.events.size).to eq(1)
      event = log.events.first
      expect(event).to be_a(Frog::Adventure::Web::Models::Events::EmotionalEvent)
      expect(event.emotion_type).to eq(:happiness_boost)
      expect(event.intensity).to eq(:strong)
    end
    
    it 'updates relationships when bond data is provided' do
      bond_data = { target: "Lily the Turtle", strength_change: 2 }
      log.log_emotion(:bond_formed, "helping with a task", :moderate, bond_data)
      
      expect(log.relationships).to have_key("Lily the Turtle")
      expect(log.relationships["Lily the Turtle"][:strength]).to eq(2)
      expect(log.relationships["Lily the Turtle"][:interactions]).to eq(1)
    end
  end
  
  describe '#log_cinematic' do
    let(:visual_elements) do
      [
        { type: :setting, description: "Sunset over the pond" },
        { type: :action, description: "Frog leaping in slow motion" }
      ]
    end
    
    it 'logs cinematic events and adds to key moments' do
      log.log_cinematic(:epic_leap, "An incredible leap across the chasm", visual_elements)
      
      expect(log.events.size).to eq(1)
      expect(log.key_moments.size).to eq(1)
      expect(log.key_moments.first).to eq(log.events.first)
    end
  end
  
  describe '#identify_story_beats' do
    before do
      # Add various events to create story beats
      log.log_choice("starting pond", "explore", { success: true })
      log.log_emotion(:happiness_boost, "beautiful sunrise", :strong)
      log.log_cinematic(:victory_dance, "Celebrating the achievement", [])
    end
    
    it 'identifies different types of story beats' do
      beats = log.identify_story_beats
      
      expect(beats).to include(
        hash_including(type: :opening),
        hash_including(type: :emotional_peak),
        hash_including(type: :climax)
      )
    end
  end
  
  describe '#analyze_character_arc' do
    it 'returns empty hash when no events' do
      expect(log.analyze_character_arc).to eq({})
    end
    
    it 'analyzes character progression' do
      # Simulate a journey
      log.instance_variable_set(:@events, [
        double(frog_state: { energy: 100, happiness: 50 }, type: 'start'),
        double(frog_state: { energy: 75, happiness: 70 }, type: 'middle'),
        double(frog_state: { energy: 60, happiness: 85 }, type: 'end')
      ])
      
      arc = log.analyze_character_arc
      
      expect(arc[:energy_journey][:start]).to eq(100)
      expect(arc[:energy_journey][:end]).to eq(60)
      expect(arc[:energy_journey][:trend]).to eq(:major_decline)
      
      expect(arc[:emotional_journey][:start]).to eq(50)
      expect(arc[:emotional_journey][:end]).to eq(85)
      expect(arc[:emotional_journey][:trend]).to eq(:major_improvement)
    end
  end
  
  describe '#export_for_narrative' do
    before do
      log.log_choice("pond", "swim", { success: true })
      log.log_action(:ability_used, "Splash")
      log.log_emotion(:happiness_boost, "sunny day", :moderate)
    end
    
    it 'exports data in narrative-friendly format' do
      export = log.export_for_narrative
      
      expect(export).to include(
        session_id: session_id,
        events: be_an(Array),
        key_moments: be_an(Array),
        story_beats: be_an(Array),
        character_arc: be_a(Hash),
        relationships: be_a(Hash),
        narrative_context: be_a(Hash),
        statistics: be_a(Hash)
      )
      
      expect(export[:statistics]).to include(
        total_events: 3,
        narrative_events: 2, # emotion and choice are narrative-worthy
        choices_made: 1,
        emotional_moments: 1
      )
    end
  end
  
  describe '#compress_old_events' do
    before do
      # Add many events
      150.times do |i|
        log.log_action(:rest, nil, { turn: i })
      end
      
      # Add a key moment
      log.log_cinematic(:special_scene, "Important moment", [])
    end
    
    it 'compresses old events while keeping recent ones' do
      initial_count = log.events.size
      compressed = log.compress_old_events(50)
      
      expect(compressed).to eq(101) # 150 + 1 - 50
      expect(log.events.size).to eq(50) # 50 recent (key moment is already in recent)
    end
    
    it 'preserves key moments regardless of age' do
      log.compress_old_events(10)
      
      cinematic_events = log.events.select { |e| e.type == 'cinematic' }
      expect(cinematic_events.size).to eq(1)
    end
  end
  
  describe 'event filtering' do
    before do
      log.log_choice("path", "left", { success: true })
      log.log_action(:rest)
      log.log_emotion(:sadness, "rain", :mild)
      log.log_cinematic(:sunset, "Beautiful sunset", [])
    end
    
    it '#events_by_type filters correctly' do
      expect(log.events_by_type(:choice).size).to eq(1)
      expect(log.events_by_type(:action).size).to eq(1)
      expect(log.events_by_type(:emotional).size).to eq(1)
      expect(log.events_by_type(:cinematic).size).to eq(1)
    end
    
    it '#narrative_events filters by importance' do
      # rest action has low importance, choice with no consequences is low, 
      # mild emotion is low, only cinematic is high importance
      expect(log.narrative_events.size).to eq(1)
    end
    
    it '#cinematic_events filters cinematic moments' do
      expect(log.cinematic_events.size).to eq(1)
      expect(log.cinematic_events.first.type).to eq('cinematic')
    end
  end
  
  describe 'serialization' do
    before do
      log.log_choice("pond", "dive", { success: true })
      log.log_emotion(:bond_formed, "meeting", :moderate, { target: "Turtle" })
    end
    
    it 'serializes to JSON' do
      json = log.to_json
      parsed = JSON.parse(json, symbolize_names: true)
      
      expect(parsed[:session_id]).to eq(session_id)
      expect(parsed[:events]).to be_an(Array)
      expect(parsed[:events].size).to eq(2)
      expect(parsed[:relationships]).to have_key(:Turtle)
    end
  end
end