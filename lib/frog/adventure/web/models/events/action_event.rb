# frozen_string_literal: true

require_relative '../game_event'

module Frog
  module Adventure
    module Web
      module Models
        module Events
          # Event for abilities used and items collected
          class ActionEvent < GameEvent
            attr_reader :action_type, :target, :result

            def initialize(action_type:, target: nil, result: {}, **kwargs)
              @action_type = action_type
              @target = target
              @result = result

              super(
                type: :action,
                data: {
                  action_type: action_type,
                  target: target,
                  result: result
                },
                **kwargs
              )
            end

            protected

            def narrative_description
              case @action_type
              when :ability_used
                ability_description
              when :item_collected
                "Found and collected #{@target}"
              when :item_used
                "Used #{@target} with #{@result[:effect] || 'some effect'}"
              when :rest
                "Took a moment to rest and recover"
              when :feed
                "Enjoyed a tasty #{@target || 'snack'}"
              else
                "Performed #{@action_type}"
              end
            end

            def ability_description
              frog_name = @frog_state ? @frog_state[:name] : "The frog"
              ability = @target || "special ability"
              
              if @result[:success]
                "#{frog_name} successfully used #{ability}!"
              else
                "#{frog_name} tried to use #{ability} but failed"
              end
            end

            def extract_visual_elements
              elements = []
              
              case @action_type
              when :ability_used
                elements << { type: :special_effect, description: "#{@target} activation" }
                elements << { type: :action, description: "Frog using special power" }
              when :item_collected
                elements << { type: :item, description: @target, highlight: true }
                elements << { type: :action, description: "Frog picking up item" }
              when :rest
                elements << { type: :setting, description: "Peaceful resting spot" }
                elements << { type: :action, description: "Frog relaxing" }
              end
              
              elements
            end
          end
        end
      end
    end
  end
end