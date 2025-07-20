# frozen_string_literal: true

require 'securerandom'
require 'json'

module Frog
  module Adventure
    module Web
      module Models
        # Base class for all game events
        class GameEvent
          attr_accessor :id, :timestamp, :type, :data, :importance, :frog_state, :metadata

          IMPORTANCE_LEVELS = {
            low: 1,
            normal: 2,
            high: 3,
            critical: 4
          }.freeze

          def initialize(type:, data: {}, importance: :normal, frog_state: nil, metadata: {})
            @id = generate_id
            @timestamp = Time.now.to_f
            @type = type.to_s
            @data = data
            @importance = importance
            @frog_state = frog_state
            @metadata = metadata

            validate!
          end

          # Convert to narrative-friendly format
          def to_narrative
            {
              id: @id,
              timestamp: @timestamp,
              type: @type,
              description: narrative_description,
              importance: @importance,
              emotional_context: extract_emotional_context,
              visual_elements: extract_visual_elements
            }
          end

          # Convert to hash for storage
          def to_h
            {
              id: @id,
              timestamp: @timestamp,
              type: @type,
              data: @data,
              importance: @importance,
              frog_state: @frog_state,
              metadata: @metadata
            }
          end

          def to_json(*args)
            to_h.to_json(*args)
          end

          # Check if this event is important enough for narrative
          def narrative_worthy?
            IMPORTANCE_LEVELS[@importance] >= IMPORTANCE_LEVELS[:normal]
          end

          # Check if this event would make a good cartoon scene
          def cinematic?
            IMPORTANCE_LEVELS[@importance] >= IMPORTANCE_LEVELS[:high]
          end

          protected

          # Override in subclasses to provide narrative description
          def narrative_description
            "#{@type} occurred"
          end

          # Override in subclasses to extract emotional context
          def extract_emotional_context
            return {} unless @frog_state

            {
              energy_level: energy_descriptor(@frog_state[:energy]),
              mood: mood_descriptor(@frog_state[:happiness]),
              condition: condition_descriptor(@frog_state)
            }
          end

          # Override in subclasses to extract visual elements
          def extract_visual_elements
            []
          end

          private

          def validate!
            raise ArgumentError, "Event type cannot be empty" if @type.nil? || @type.empty?
            raise ArgumentError, "Invalid importance level" unless IMPORTANCE_LEVELS.key?(@importance)
          end

          def generate_id
            "event_#{@type}_#{SecureRandom.hex(8)}"
          end

          def energy_descriptor(energy)
            case energy
            when 0..20 then "exhausted"
            when 21..40 then "tired"
            when 41..60 then "moderate"
            when 61..80 then "energetic"
            when 81..100 then "vibrant"
            else "unknown"
            end
          end

          def mood_descriptor(happiness)
            case happiness
            when 0..20 then "depressed"
            when 21..40 then "sad"
            when 41..60 then "content"
            when 61..80 then "happy"
            when 81..100 then "ecstatic"
            else "unknown"
            end
          end

          def condition_descriptor(state)
            conditions = []
            conditions << "tired" if state[:energy] < 20
            conditions << "sad" if state[:happiness] < 30
            conditions << "injured" if state[:health] && state[:health] < 50
            conditions << "hungry" if state[:hunger] && state[:hunger] > 70
            conditions.empty? ? "normal" : conditions.join(", ")
          end
        end
      end
    end
  end
end