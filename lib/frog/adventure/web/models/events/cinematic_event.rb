# frozen_string_literal: true

require_relative '../game_event'

module Frog
  module Adventure
    module Web
      module Models
        module Events
          # Special events that would make good cartoon scenes
          class CinematicEvent < GameEvent
            attr_reader :scene_type, :description, :visual_elements, :duration

            def initialize(scene_type:, description:, visual_elements:, duration: :normal, **kwargs)
              @scene_type = scene_type
              @description = description
              @visual_elements = visual_elements
              @duration = duration

              super(
                type: :cinematic,
                data: {
                  scene_type: scene_type,
                  description: description,
                  visual_elements: visual_elements,
                  duration: duration
                },
                importance: :high, # Cinematic events are always important
                **kwargs
              )
            end
            
            # Override to always be true for cinematic events
            def cinematic?
              true
            end

            protected

            def narrative_description
              @description
            end

            def extract_visual_elements
              # Already have detailed visual elements
              @visual_elements.map do |element|
                if element.is_a?(Hash)
                  element
                else
                  { type: :visual, description: element }
                end
              end
            end
          end
        end
      end
    end
  end
end