# frozen_string_literal: true

require 'json'

module Frog
  module Adventure
    module Web
      # Manages game events and their handlers
      class GameEventSystem
        attr_reader :game_id, :handlers, :event_history

        # Define common event types
        EVENTS = {
          # Frog-related events
          frog_level_up: 'frog_level_up',
          frog_tired: 'frog_tired',
          frog_happy: 'frog_happy',
          frog_sad: 'frog_sad',
          frog_ability_used: 'frog_ability_used',
          frog_item_found: 'frog_item_found',

          # Game progression events
          adventure_started: 'adventure_started',
          adventure_completed: 'adventure_completed',
          adventure_failed: 'adventure_failed',
          new_area_unlocked: 'new_area_unlocked',
          achievement_unlocked: 'achievement_unlocked',

          # Game state events
          game_won: 'game_won',
          game_lost: 'game_lost',
          turn_completed: 'turn_completed',
          save_game: 'save_game',

          # Special events
          random_encounter: 'random_encounter',
          weather_change: 'weather_change',
          special_discovery: 'special_discovery'
        }.freeze

        def initialize(game_id)
          @game_id = game_id
          @handlers = {}
          @event_history = []
          @middleware = []
        end

        # Register an event handler
        def register_handler(event_type, &block)
          validate_event_type!(event_type)
          raise ArgumentError, "Handler block is required" unless block_given?

          @handlers[event_type.to_s] ||= []
          @handlers[event_type.to_s] << block
        end

        # Register middleware that runs before all events
        def register_middleware(&block)
          raise ArgumentError, "Middleware block is required" unless block_given?
          @middleware << block
        end

        # Trigger an event with data
        def trigger(event_type, data = {})
          validate_event_type!(event_type)
          
          event = create_event(event_type, data)
          @event_history << event

          # Run middleware first
          @middleware.each do |middleware|
            begin
              middleware.call(event)
            rescue => e
              # Log middleware error but don't stop event processing
              event[:middleware_errors] ||= []
              event[:middleware_errors] << { error: e.message, backtrace: e.backtrace }
            end
          end

          # Process handlers for this event type
          handlers = @handlers[event_type.to_s] || []
          results = []

          handlers.each_with_index do |handler, index|
            begin
              result = handler.call(event)
              results << { handler_index: index, result: result, success: true }
            rescue => e
              results << { 
                handler_index: index, 
                error: e.message, 
                backtrace: e.backtrace, 
                success: false 
              }
            end
          end

          event[:handler_results] = results
          event[:processed_at] = Time.now.to_f
          event
        end

        # Process all pending events (useful for batch processing)
        def process_events
          # For now, this is a no-op since we process events immediately
          # But this could be enhanced for batch processing in the future
          @event_history.select { |event| event[:processed_at] }
        end

        # Get events by type
        def events_by_type(event_type)
          @event_history.select { |event| event[:type] == event_type.to_s }
        end

        # Get recent events (last N events)
        def recent_events(limit = 10)
          @event_history.last(limit)
        end

        # Clear event history
        def clear_history
          @event_history.clear
        end

        # Get event statistics
        def stats
          {
            total_events: @event_history.size,
            events_by_type: @event_history.group_by { |e| e[:type] }.transform_values(&:size),
            registered_handlers: @handlers.transform_values(&:size),
            middleware_count: @middleware.size,
            recent_activity: recent_events(5)
          }
        end

        # Remove handlers for an event type
        def clear_handlers(event_type)
          @handlers.delete(event_type.to_s)
        end

        # Remove all handlers
        def clear_all_handlers
          @handlers.clear
        end

        # Check if event type has handlers
        def has_handlers?(event_type)
          handlers = @handlers[event_type.to_s]
          handlers && !handlers.empty?
        end

        # Serialize event system state
        def to_json(*args)
          {
            game_id: @game_id,
            event_history: @event_history,
            handler_count: @handlers.transform_values(&:size),
            middleware_count: @middleware.size,
            created_at: Time.now.to_f
          }.to_json(*args)
        end

        # Helper methods for common event triggers
        def trigger_frog_state_change(frog, previous_state, new_state)
          trigger(:frog_state_change, {
            frog: frog.to_h,
            previous_state: previous_state,
            new_state: new_state
          })
        end

        def trigger_adventure_complete(adventure_data, success:)
          event_type = success ? :adventure_completed : :adventure_failed
          trigger(event_type, adventure_data)
        end

        def trigger_turn_complete(turn_number, actions_processed)
          trigger(:turn_completed, {
            turn_number: turn_number,
            actions_processed: actions_processed,
            timestamp: Time.now.to_f
          })
        end

        private

        def create_event(event_type, data)
          {
            id: generate_event_id,
            type: event_type.to_s,
            data: data,
            game_id: @game_id,
            triggered_at: Time.now.to_f,
            processed_at: nil,
            handler_results: nil,
            middleware_errors: nil
          }
        end

        def validate_event_type!(event_type)
          raise ArgumentError, "Event type cannot be nil" if event_type.nil?
          raise ArgumentError, "Event type must be a string or symbol" unless event_type.respond_to?(:to_s)
        end

        def generate_event_id
          "event_#{@game_id}_#{Time.now.to_f}_#{rand(10000)}"
        end
      end
    end
  end
end