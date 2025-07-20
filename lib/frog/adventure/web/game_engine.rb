# frozen_string_literal: true

require_relative "action_queue"
require_relative "game_event_system"
require_relative "llm_client"

module Frog
  module Adventure
    module Web
      # Core game engine that manages game state and logic
      class GameEngine
        attr_reader :game_id, :state, :action_queue, :event_system, :turn_number

        # Game state constants
        GAME_STATES = {
          new: 'new',
          playing: 'playing',
          paused: 'paused',
          won: 'won',
          lost: 'lost'
        }.freeze

        def initialize(game_id)
          @game_id = game_id
          @state = {}
          @action_queue = ActionQueue.new(game_id)
          @event_system = GameEventSystem.new(game_id)
          @turn_number = 0
          @llm_client = LLMClient.new

          setup_event_handlers
        end

        # Start a new game with a randomly generated frog
        def start_new_game
          frog = @llm_client.generate_frog
          
          @state = {
            game_state: GAME_STATES[:playing],
            frog: frog.to_h,
            adventures_completed: 0,
            current_scenario: nil,
            total_turns: 0,
            created_at: Time.now.to_f,
            last_save: nil,
            achievements: [],
            unlocked_areas: ['starting_forest']
          }

          @turn_number = 0
          @event_system.trigger(:game_started, { frog: frog.to_h })
          auto_save
          
          @state
        end

        # Process a player action by adding it to the queue
        def enqueue_action(action_type, action_data = {}, priority: :normal)
          action_id = @action_queue.enqueue(action_type, action_data, priority: priority)
          @event_system.trigger(:action_queued, { 
            action_id: action_id, 
            action_type: action_type, 
            action_data: action_data 
          })
          action_id
        end

        # Process the next turn (main game loop)
        def process_turn
          return { success: false, message: "Game not in playing state" } unless game_playing?

          @turn_number += 1
          @state[:total_turns] = @turn_number
          
          actions_processed = []
          
          # 1. Process all queued actions
          while !@action_queue.empty?
            processed_action = @action_queue.process_next do |action|
              process_single_action(action)
            end
            actions_processed << processed_action if processed_action
          end

          # 2. Update frog stats (hunger, energy decay)
          update_frog_stats

          # 3. Check for triggered events
          check_environmental_events

          # 4. Evaluate win/loss conditions
          game_result = check_win_loss_conditions

          # 5. Auto-save if still playing
          auto_save if game_playing?

          # 6. Trigger turn completed event
          @event_system.trigger_turn_complete(@turn_number, actions_processed.size)

          # 7. Return results
          {
            success: true,
            turn_number: @turn_number,
            actions_processed: actions_processed,
            frog_state: current_frog,
            game_state: @state[:game_state],
            game_result: game_result,
            events: @event_system.recent_events(5)
          }
        end

        # Get current frog model
        def current_frog
          return nil unless @state[:frog]
          Models::Frog.from_hash(@state[:frog])
        end

        # Check if game is in playing state
        def game_playing?
          @state[:game_state] == GAME_STATES[:playing]
        end

        # Save game state to persistence layer
        def save
          @state[:last_save] = Time.now.to_f
          # TODO: Implement Redis persistence
          # For now, just mark as saved
          @event_system.trigger(:save_game, { timestamp: @state[:last_save] })
          true
        end

        # Load game state from persistence layer
        def load
          # TODO: Implement Redis loading
          # For now, just return current state
          @state
        end

        # Get game statistics
        def stats
          {
            game_id: @game_id,
            turn_number: @turn_number,
            game_state: @state[:game_state],
            adventures_completed: @state[:adventures_completed],
            action_queue_stats: @action_queue.stats,
            event_stats: @event_system.stats,
            frog_stats: current_frog&.stats,
            created_at: @state[:created_at],
            last_save: @state[:last_save]
          }
        end

        private

        def setup_event_handlers
          # Register event handlers for common game events
          @event_system.register_handler(:frog_tired) do |event|
            frog = current_frog
            if frog&.tired?
              enqueue_action(:auto_rest, {}, priority: :high)
            end
          end

          @event_system.register_handler(:frog_sad) do |event|
            # Trigger random positive event to cheer up the frog
            enqueue_action(:random_encounter, { type: :positive }, priority: :normal)
          end

          @event_system.register_handler(:achievement_unlocked) do |event|
            achievement = event[:data][:achievement]
            @state[:achievements] << achievement unless @state[:achievements].include?(achievement)
          end
        end

        def process_single_action(action)
          action_type = action[:type]
          params = action[:params]

          case action_type
          when 'move'
            process_move_action(params)
          when 'use_ability'
            process_ability_action(params)
          when 'rest'
            process_rest_action(params)
          when 'feed'
            process_feed_action(params)
          when 'adventure'
            process_adventure_action(params)
          when 'interact'
            process_interact_action(params)
          when 'auto_rest'
            process_auto_rest_action(params)
          when 'random_encounter'
            process_random_encounter(params)
          else
            { success: false, message: "Unknown action type: #{action_type}" }
          end
        end

        def process_move_action(params)
          direction = params[:direction]
          # Simple movement - could be enhanced with area maps
          @event_system.trigger(:frog_moved, { direction: direction })
          { success: true, message: "Moved #{direction}" }
        end

        def process_ability_action(params)
          frog = current_frog
          return { success: false, message: "No frog found" } unless frog

          if frog.can_use_ability?
            frog.use_ability!
            @state[:frog] = frog.to_h
            @event_system.trigger(:frog_ability_used, { ability: frog.ability, power: frog.ability_power })
            { success: true, message: "Used ability: #{frog.ability}", power: frog.ability_power }
          else
            { success: false, message: "Ability on cooldown (#{frog.ability_cooldown} turns)" }
          end
        end

        def process_rest_action(params)
          frog = current_frog
          return { success: false, message: "No frog found" } unless frog

          energy_gain = rand(15..25)
          happiness_gain = rand(5..10)
          
          frog.adjust_energy(energy_gain)
          frog.adjust_happiness(happiness_gain)
          @state[:frog] = frog.to_h

          @event_system.trigger(:frog_rested, { 
            energy_gain: energy_gain, 
            happiness_gain: happiness_gain,
            new_energy: frog.energy,
            new_happiness: frog.happiness
          })

          { success: true, message: "Frog rested", energy_gain: energy_gain, happiness_gain: happiness_gain }
        end

        def process_feed_action(params)
          frog = current_frog
          food = params[:food]
          return { success: false, message: "No frog found" } unless frog

          # Remove food from inventory if specified
          if frog.items.include?(food)
            frog.remove_item(food)
            energy_gain = rand(10..20)
            happiness_gain = rand(8..15)
          else
            # Use generic food
            energy_gain = rand(5..10)
            happiness_gain = rand(3..8)
          end

          frog.adjust_energy(energy_gain)
          frog.adjust_happiness(happiness_gain)
          @state[:frog] = frog.to_h

          @event_system.trigger(:frog_fed, { 
            food: food, 
            energy_gain: energy_gain, 
            happiness_gain: happiness_gain 
          })

          { success: true, message: "Fed frog #{food}", energy_gain: energy_gain, happiness_gain: happiness_gain }
        end

        def process_adventure_action(params)
          scenario_id = params[:scenario_id]
          frog = current_frog
          return { success: false, message: "No frog found" } unless frog

          # Simple adventure system
          success_chance = calculate_adventure_success_chance(frog)
          success = rand < success_chance

          if success
            @state[:adventures_completed] += 1
            reward = generate_adventure_reward(frog)
            
            if reward[:item]
              frog.add_item(reward[:item])
            end
            
            frog.adjust_happiness(reward[:happiness])
            frog.adjust_energy(-reward[:energy_cost])
            @state[:frog] = frog.to_h

            @event_system.trigger(:adventure_completed, { 
              scenario_id: scenario_id, 
              reward: reward,
              adventures_total: @state[:adventures_completed]
            })

            { success: true, message: "Adventure completed!", reward: reward }
          else
            energy_cost = rand(10..20)
            frog.adjust_energy(-energy_cost)
            @state[:frog] = frog.to_h

            @event_system.trigger(:adventure_failed, { 
              scenario_id: scenario_id, 
              energy_cost: energy_cost 
            })

            { success: false, message: "Adventure failed", energy_cost: energy_cost }
          end
        end

        def process_interact_action(params)
          target = params[:target]
          @event_system.trigger(:frog_interacted, { target: target })
          { success: true, message: "Interacted with #{target}" }
        end

        def process_auto_rest_action(params)
          # Automatic rest when frog is tired
          process_rest_action(params)
        end

        def process_random_encounter(params)
          encounter_type = params[:type] || [:positive, :neutral, :negative].sample
          frog = current_frog
          return { success: false, message: "No frog found" } unless frog

          case encounter_type
          when :positive
            happiness_gain = rand(10..20)
            frog.adjust_happiness(happiness_gain)
            message = "Found a shiny lily pad! +#{happiness_gain} happiness"
          when :negative
            energy_loss = rand(5..15)
            frog.adjust_energy(-energy_loss)
            message = "Encountered a snake! -#{energy_loss} energy"
          else # neutral
            message = "Saw some interesting insects nearby"
          end

          @state[:frog] = frog.to_h
          @event_system.trigger(:random_encounter, { type: encounter_type, message: message })
          
          { success: true, message: message }
        end

        def update_frog_stats
          frog = current_frog
          return unless frog

          # Natural energy and happiness decay each turn
          energy_decay = rand(1..3)
          happiness_decay = rand(0..2)

          frog.adjust_energy(-energy_decay)
          frog.adjust_happiness(-happiness_decay)
          frog.reduce_cooldown!

          @state[:frog] = frog.to_h

          # Trigger events based on frog state
          @event_system.trigger(:frog_tired, { frog: frog.to_h }) if frog.tired?
          @event_system.trigger(:frog_sad, { frog: frog.to_h }) if frog.sad?
          @event_system.trigger(:frog_happy, { frog: frog.to_h }) if frog.happy?
        end

        def check_environmental_events
          # Random environmental events
          if rand < 0.1 # 10% chance per turn
            event_types = [:weather_change, :special_discovery, :random_encounter]
            event_type = event_types.sample
            @event_system.trigger(event_type, { turn: @turn_number })
          end
        end

        def check_win_loss_conditions
          frog = current_frog
          return nil unless frog

          # Win condition: Frog reaches max happiness and completes many adventures
          if frog.happiness >= 90 && @state[:adventures_completed] >= 10
            @state[:game_state] = GAME_STATES[:won]
            @event_system.trigger(:game_won, { 
              final_stats: frog.to_h, 
              adventures_completed: @state[:adventures_completed],
              turns_taken: @turn_number
            })
            return { result: :won, message: "Congratulations! Your frog achieved ultimate happiness!" }
          end

          # Loss condition: Frog energy depleted for too long or happiness at 0
          if frog.energy <= 0 || frog.happiness <= 0
            @state[:game_state] = GAME_STATES[:lost]
            @event_system.trigger(:game_lost, { 
              final_stats: frog.to_h, 
              reason: frog.energy <= 0 ? "energy_depleted" : "too_sad"
            })
            return { result: :lost, message: "Game over! Your frog needs better care." }
          end

          nil
        end

        def calculate_adventure_success_chance(frog)
          base_chance = 0.6
          
          # Adjust based on frog stats
          stat_bonus = (frog.total_stats - 55) * 0.01 # +1% per stat point above average
          energy_bonus = frog.energy > 50 ? 0.1 : -0.1
          happiness_bonus = frog.happiness > 50 ? 0.1 : -0.1
          
          [base_chance + stat_bonus + energy_bonus + happiness_bonus, 0.1, 0.9].sort[1]
        end

        def generate_adventure_reward(frog)
          rewards = {
            energy_cost: rand(5..15),
            happiness: rand(10..20),
            experience: rand(1..5)
          }

          # Chance for item reward
          if rand < 0.3 # 30% chance
            items = ["Shiny Rock", "Magic Berry", "Golden Lily Pad", "Ancient Acorn", "Crystal Dewdrop"]
            rewards[:item] = items.sample
          end

          rewards
        end

        def auto_save
          save if @turn_number % 5 == 0 # Auto-save every 5 turns
        end
      end
    end
  end
end