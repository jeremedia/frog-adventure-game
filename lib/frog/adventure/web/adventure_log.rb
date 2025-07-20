# frozen_string_literal: true

require 'json'
require_relative 'models/game_event'
require_relative 'models/events/choice_event'
require_relative 'models/events/action_event'
require_relative 'models/events/emotional_event'
require_relative 'models/events/cinematic_event'

module Frog
  module Adventure
    module Web
      # Comprehensive logging system for recording game events for narrative generation
      class AdventureLog
        attr_reader :session_id, :events, :key_moments, :relationships, :story_arcs

        def initialize(session_id)
          @session_id = session_id
          @events = []
          @key_moments = []
          @relationships = {}
          @story_arcs = []
          @event_index = {}
          @narrative_context = {
            themes: [],
            tone: :whimsical,
            pacing: :moderate
          }
        end

        # Log a player choice and its outcome
        def log_choice(scenario, choice, outcome, consequences = {})
          event = Models::Events::ChoiceEvent.new(
            scenario: scenario,
            choice: choice,
            outcome: outcome,
            consequences: consequences,
            frog_state: capture_current_frog_state,
            importance: determine_choice_importance(outcome, consequences)
          )

          add_event(event)
          analyze_for_story_beat(event)
        end

        # Log an action event
        def log_action(action_type, target = nil, result = {})
          importance = action_type == :ability_used ? :normal : :low
          
          event = Models::Events::ActionEvent.new(
            action_type: action_type,
            target: target,
            result: result,
            frog_state: capture_current_frog_state,
            importance: importance
          )

          add_event(event)
        end

        # Log an emotional event
        def log_emotion(emotion_type, trigger, intensity = :moderate, bond_data = nil)
          event = Models::Events::EmotionalEvent.new(
            emotion_type: emotion_type,
            trigger: trigger,
            intensity: intensity,
            bond_data: bond_data,
            frog_state: capture_current_frog_state
          )

          add_event(event)
          update_relationships(bond_data) if bond_data
        end

        # Log a cinematic moment
        def log_cinematic(scene_type, description, visual_elements, duration = :normal)
          event = Models::Events::CinematicEvent.new(
            scene_type: scene_type,
            description: description,
            visual_elements: visual_elements,
            duration: duration,
            frog_state: capture_current_frog_state
          )

          add_event(event)
        end

        # Get events by type
        def events_by_type(type)
          @events.select { |e| e.type == type.to_s }
        end

        # Get narrative-worthy events
        def narrative_events
          @events.select(&:narrative_worthy?)
        end

        # Get cinematic events
        def cinematic_events
          @events.select(&:cinematic?)
        end

        # Analyze the log for key story beats
        def identify_story_beats
          beats = []
          
          # Opening - first significant event
          first_choice = events_by_type(:choice).first
          beats << { type: :opening, event: first_choice } if first_choice
          
          # Turning points - major successes or failures
          major_outcomes = @events.select do |e|
            e.type == 'choice' && e.data[:outcome][:major_impact]
          end
          beats.concat(major_outcomes.map { |e| { type: :turning_point, event: e } })
          
          # Emotional peaks
          strong_emotions = events_by_type(:emotional).select do |e|
            [:strong, :overwhelming].include?(e.data[:intensity])
          end
          beats.concat(strong_emotions.map { |e| { type: :emotional_peak, event: e } })
          
          # Climax - most important recent event
          if @key_moments.any?
            climax = @key_moments.last
            beats << { type: :climax, event: climax }
          end
          
          beats
        end

        # Analyze character arc
        def analyze_character_arc
          return {} if @events.empty?
          
          first_state = @events.first.frog_state
          last_state = @events.last.frog_state
          
          return {} unless first_state && last_state
          
          {
            energy_journey: {
              start: first_state[:energy],
              end: last_state[:energy],
              trend: calculate_trend(first_state[:energy], last_state[:energy])
            },
            emotional_journey: {
              start: first_state[:happiness],
              end: last_state[:happiness],
              trend: calculate_trend(first_state[:happiness], last_state[:happiness])
            },
            abilities_gained: extract_abilities_gained,
            relationships_formed: @relationships.keys,
            items_collected: extract_items_collected,
            challenges_overcome: count_successful_challenges
          }
        end

        # Export log for narrative generation
        def export_for_narrative
          {
            session_id: @session_id,
            events: narrative_events.map(&:to_narrative),
            key_moments: @key_moments.map(&:to_narrative),
            story_beats: identify_story_beats,
            character_arc: analyze_character_arc,
            relationships: @relationships,
            narrative_context: @narrative_context,
            statistics: generate_statistics
          }
        end

        # Compress and archive old events
        def compress_old_events(keep_recent = 100)
          return if @events.size <= keep_recent
          
          # Archive old events
          archived = @events[0...-keep_recent]
          @events = @events[-keep_recent..-1]
          
          # Keep key moments regardless of age
          @key_moments.each do |moment|
            @events << moment unless @events.include?(moment)
          end
          
          archived.size
        end

        # Serialize to JSON
        def to_json(*args)
          {
            session_id: @session_id,
            events: @events.map(&:to_h),
            key_moments: @key_moments.map(&:id),
            relationships: @relationships,
            story_arcs: @story_arcs,
            narrative_context: @narrative_context
          }.to_json(*args)
        end

        # Load from JSON
        def self.from_json(json_string)
          data = JSON.parse(json_string, symbolize_names: true)
          log = new(data[:session_id])
          
          # Recreate events (simplified - in practice would need proper deserialization)
          # This is a placeholder for the actual implementation
          log
        end

        private

        def add_event(event)
          @events << event
          @event_index[event.id] = event
          analyze_for_key_moment(event) if event.importance != :low
        end

        def capture_current_frog_state
          # This would be connected to the actual game state
          # For now, return a placeholder
          {
            name: "Hoppy",
            energy: 75,
            happiness: 60,
            items: [],
            abilities_available: true
          }
        end

        def determine_choice_importance(outcome, consequences)
          return :critical if consequences[:game_ending]
          return :high if consequences[:major_impact] || consequences[:location_unlocked]
          return :normal if outcome[:success] && consequences[:item_gained]
          :low
        end

        def analyze_for_story_beat(event)
          # Check if this event creates or resolves a story arc
          if event.data[:consequences][:starts_arc]
            @story_arcs << {
              id: "arc_#{@story_arcs.size + 1}",
              start_event: event.id,
              theme: event.data[:consequences][:arc_theme],
              status: :active
            }
          elsif event.data[:consequences][:resolves_arc]
            arc = @story_arcs.find { |a| a[:status] == :active }
            if arc
              arc[:end_event] = event.id
              arc[:status] = :resolved
            end
          end
        end

        def analyze_for_key_moment(event)
          # Events become key moments if they're highly important or cinematic
          if event.importance == :critical || event.cinematic?
            @key_moments << event
          end
        end

        def update_relationships(bond_data)
          return unless bond_data
          
          target = bond_data[:target]
          @relationships[target] ||= { strength: 0, interactions: 0 }
          @relationships[target][:strength] += bond_data[:strength_change] || 1
          @relationships[target][:interactions] += 1
        end

        def calculate_trend(start_value, end_value)
          diff = end_value - start_value
          case diff
          when -100..-20 then :major_decline
          when -19..-5 then :decline
          when -4..4 then :stable
          when 5..19 then :improvement
          when 20..100 then :major_improvement
          end
        end

        def extract_abilities_gained
          events_by_type(:action).select do |e|
            e.data[:action_type] == :ability_unlocked
          end.map { |e| e.data[:target] }
        end

        def extract_items_collected
          events_by_type(:action).select do |e|
            e.data[:action_type] == :item_collected
          end.map { |e| e.data[:target] }
        end

        def count_successful_challenges
          events_by_type(:choice).count do |e|
            e.data[:outcome][:success] && e.data[:outcome][:challenge]
          end
        end

        def generate_statistics
          {
            total_events: @events.size,
            narrative_events: narrative_events.size,
            key_moments: @key_moments.size,
            choices_made: events_by_type(:choice).size,
            emotional_moments: events_by_type(:emotional).size,
            relationships_formed: @relationships.size,
            story_arcs_completed: @story_arcs.count { |a| a[:status] == :resolved }
          }
        end
      end
    end
  end
end