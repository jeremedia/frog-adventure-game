# frozen_string_literal: true

require_relative '../game_event'

module Frog
  module Adventure
    module Web
      module Models
        module Events
          # Event for frog mood changes and bonds formed
          class EmotionalEvent < GameEvent
            attr_reader :emotion_type, :trigger, :intensity, :bond_data

            def initialize(emotion_type:, trigger:, intensity: :moderate, bond_data: nil, **kwargs)
              @emotion_type = emotion_type
              @trigger = trigger
              @intensity = intensity
              @bond_data = bond_data

              super(
                type: :emotional,
                data: {
                  emotion_type: emotion_type,
                  trigger: trigger,
                  intensity: intensity,
                  bond_data: bond_data
                },
                importance: calculate_importance(intensity),
                **kwargs
              )
            end

            protected

            def narrative_description
              frog_name = @frog_state ? @frog_state[:name] : "The frog"
              
              case @emotion_type
              when :happiness_boost
                "#{frog_name} felt a surge of joy from #{@trigger}"
              when :sadness
                "#{frog_name} became sad due to #{@trigger}"
              when :excitement
                "#{frog_name} became excited about #{@trigger}"
              when :fear
                "#{frog_name} felt frightened by #{@trigger}"
              when :bond_formed
                "#{frog_name} formed a special bond with #{@bond_data[:target]}"
              when :bond_strengthened
                "The bond with #{@bond_data[:target]} grew stronger"
              else
                "#{frog_name} experienced #{@emotion_type}"
              end
            end

            def extract_visual_elements
              elements = []
              
              # Emotional expression
              elements << { 
                type: :expression, 
                description: "Frog showing #{@emotion_type}",
                intensity: @intensity
              }
              
              # Environmental reflection of emotion
              case @emotion_type
              when :happiness_boost, :excitement
                elements << { type: :effect, description: "Sparkles or light effects" }
              when :sadness
                elements << { type: :effect, description: "Rain or drooping surroundings" }
              when :fear
                elements << { type: :effect, description: "Dark shadows or trembling" }
              when :bond_formed, :bond_strengthened
                elements << { 
                  type: :effect, 
                  description: "Glowing connection between characters" 
                }
              end
              
              elements
            end

            private

            def calculate_importance(intensity)
              case intensity
              when :mild then :low
              when :moderate then :normal
              when :strong then :high
              when :overwhelming then :critical
              else :normal
              end
            end
          end
        end
      end
    end
  end
end