# frozen_string_literal: true

require_relative '../game_event'

module Frog
  module Adventure
    module Web
      module Models
        module Events
          # Event for player choices and their outcomes
          class ChoiceEvent < GameEvent
            attr_reader :scenario, :choice, :outcome, :consequences

            def initialize(scenario:, choice:, outcome:, consequences: {}, **kwargs)
              @scenario = scenario
              @choice = choice
              @outcome = outcome
              @consequences = consequences

              super(
                type: :choice,
                data: {
                  scenario: scenario,
                  choice: choice,
                  outcome: outcome,
                  consequences: consequences
                },
                **kwargs
              )
            end

            protected

            def narrative_description
              base = "Faced with #{@scenario}, chose to #{@choice}."
              result = @outcome[:success] ? "succeeded" : "failed"
              details = @outcome[:message] || ""
              
              "#{base} The attempt #{result}. #{details}".strip
            end

            def extract_visual_elements
              elements = []
              elements << { type: :setting, description: @scenario }
              elements << { type: :action, description: @choice }
              
              if @consequences[:item_gained]
                elements << { type: :item, description: @consequences[:item_gained] }
              end
              
              if @consequences[:location_unlocked]
                elements << { type: :location, description: @consequences[:location_unlocked] }
              end
              
              elements
            end
          end
        end
      end
    end
  end
end