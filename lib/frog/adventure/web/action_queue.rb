# frozen_string_literal: true

require 'json'

module Frog
  module Adventure
    module Web
      # Manages the queue of actions to be processed in the game loop
      class ActionQueue
        attr_reader :game_id, :actions

        def initialize(game_id)
          @game_id = game_id
          @actions = []
        end

        # Enqueue a new action to be processed
        def enqueue(action_type, params = {}, priority: :normal)
          validate_action!(action_type, params)
          
          action = {
            id: generate_action_id,
            type: action_type.to_s,
            params: params,
            priority: priority,
            queued_at: Time.now.to_f,
            status: :pending
          }

          case priority
          when :high
            @actions.unshift(action)
          when :low
            @actions.push(action)
          else # :normal
            # Insert before any low-priority actions
            low_priority_index = @actions.index { |a| a[:priority] == :low }
            if low_priority_index
              @actions.insert(low_priority_index, action)
            else
              @actions.push(action)
            end
          end

          action[:id]
        end

        # Process the next action in the queue
        def process_next
          return nil if @actions.empty?

          action = @actions.shift
          action[:status] = :processing
          action[:started_at] = Time.now.to_f

          begin
            result = yield(action) if block_given?
            action[:status] = :completed
            action[:completed_at] = Time.now.to_f
            action[:result] = result
            action
          rescue => e
            action[:status] = :failed
            action[:error] = e.message
            action[:failed_at] = Time.now.to_f
            action
          end
        end

        # Clear all pending actions
        def clear
          @actions.clear
        end

        # Get all pending actions
        def pending_actions
          @actions.select { |action| action[:status] == :pending }
        end

        # Get actions by status
        def actions_by_status(status)
          @actions.select { |action| action[:status] == status }
        end

        # Remove specific action by ID
        def remove_action(action_id)
          @actions.reject! { |action| action[:id] == action_id }
        end

        # Check if queue is empty
        def empty?
          @actions.empty?
        end

        # Get queue size
        def size
          @actions.size
        end

        # Peek at next action without removing it
        def peek_next
          @actions.first
        end

        # Get actions by type
        def actions_by_type(action_type)
          @actions.select { |action| action[:type] == action_type.to_s }
        end

        # Get queue statistics
        def stats
          {
            total: @actions.size,
            pending: actions_by_status(:pending).size,
            processing: actions_by_status(:processing).size,
            completed: actions_by_status(:completed).size,
            failed: actions_by_status(:failed).size,
            by_priority: {
              high: @actions.count { |a| a[:priority] == :high },
              normal: @actions.count { |a| a[:priority] == :normal },
              low: @actions.count { |a| a[:priority] == :low }
            }
          }
        end

        # Serialize queue to JSON
        def to_json(*args)
          {
            game_id: @game_id,
            actions: @actions,
            created_at: Time.now.to_f
          }.to_json(*args)
        end

        # Load queue from JSON
        def self.from_json(json_string)
          data = JSON.parse(json_string, symbolize_names: true)
          queue = new(data[:game_id])
          queue.instance_variable_set(:@actions, data[:actions] || [])
          queue
        end

        private

        # Validate action type and parameters
        def validate_action!(action_type, params)
          raise ArgumentError, "Action type cannot be nil" if action_type.nil?
          raise ArgumentError, "Action type must be a string or symbol" unless action_type.respond_to?(:to_s)
          raise ArgumentError, "Params must be a hash" unless params.is_a?(Hash)

          # Validate specific action types
          case action_type.to_s
          when 'move'
            raise ArgumentError, "Move action requires direction" unless params[:direction]
          when 'use_ability'
            raise ArgumentError, "Use ability action requires ability name" unless params[:ability]
          when 'interact'
            raise ArgumentError, "Interact action requires target" unless params[:target]
          when 'rest'
            # Rest action doesn't require additional params
          when 'feed'
            raise ArgumentError, "Feed action requires food item" unless params[:food]
          when 'adventure'
            raise ArgumentError, "Adventure action requires scenario_id" unless params[:scenario_id]
          end
        end

        # Generate unique action ID
        def generate_action_id
          "action_#{@game_id}_#{Time.now.to_f}_#{rand(10000)}"
        end
      end
    end
  end
end