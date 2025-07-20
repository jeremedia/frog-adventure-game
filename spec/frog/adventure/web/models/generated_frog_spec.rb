# frozen_string_literal: true

require 'spec_helper'
require 'frog/adventure/web/models'

RSpec.describe Frog::Adventure::Web::Models::GeneratedFrog do
  let(:valid_attributes) do
    {
      name: "Nebula",
      species: "Cosmic Tree Frog",
      appearance: "Iridescent purple skin with stars",
      personality: "Wise and mysterious",
      special_ability: "Star Jump",
      ability_description: "Can teleport between lily pads",
      favorite_food: "Moonlight moths",
      unique_trait: "Glows in the dark",
      backstory: "Born from a fallen star"
    }
  end

  describe '#initialize' do
    context 'with valid attributes' do
      it 'creates a generated frog' do
        frog = described_class.new(**valid_attributes)
        
        expect(frog.name).to eq("Nebula")
        expect(frog.species).to eq("Cosmic Tree Frog")
        expect(frog.appearance).to eq("Iridescent purple skin with stars")
        expect(frog.personality).to eq("Wise and mysterious")
        expect(frog.special_ability).to eq("Star Jump")
        expect(frog.ability_description).to eq("Can teleport between lily pads")
        expect(frog.favorite_food).to eq("Moonlight moths")
        expect(frog.unique_trait).to eq("Glows in the dark")
        expect(frog.backstory).to eq("Born from a fallen star")
      end
    end

    context 'with invalid attributes' do
      %i[name species appearance personality special_ability 
         ability_description favorite_food unique_trait backstory].each do |attr|
        it "raises error for empty #{attr}" do
          invalid_attrs = valid_attributes.merge(attr => "")
          expect {
            described_class.new(**invalid_attrs)
          }.to raise_error(ArgumentError, "#{attr} cannot be empty")
        end

        it "raises error for nil #{attr}" do
          invalid_attrs = valid_attributes.merge(attr => nil)
          expect {
            described_class.new(**invalid_attrs)
          }.to raise_error(ArgumentError, "#{attr} cannot be empty")
        end
      end
    end
  end

  describe '#to_frog' do
    let(:generated_frog) { described_class.new(**valid_attributes) }
    let(:frog) { generated_frog.to_frog }

    it 'converts to a Frog instance' do
      expect(frog).to be_a(Frog::Adventure::Web::Models::Frog)
    end

    it 'sets correct attributes on Frog' do
      expect(frog.name).to eq("Nebula")
      expect(frog.frog_type).to eq(Frog::Adventure::Web::Models::FrogType::CUSTOM)
      expect(frog.ability).to eq("Star Jump")
      expect(frog.description).to eq("Iridescent purple skin with stars Wise and mysterious")
      expect(frog.species).to eq("Cosmic Tree Frog")
      expect(frog.personality).to eq("Wise and mysterious")
      expect(frog.backstory).to eq("Born from a fallen star")
    end

    it 'sets default values for Frog' do
      expect(frog.energy).to eq(100)
      expect(frog.happiness).to eq(50)
      expect(frog.items).to eq([])
    end
  end

  describe '#to_h' do
    let(:generated_frog) { described_class.new(**valid_attributes) }

    it 'returns hash representation' do
      hash = generated_frog.to_h
      
      expect(hash).to eq({
        name: "Nebula",
        species: "Cosmic Tree Frog",
        appearance: "Iridescent purple skin with stars",
        personality: "Wise and mysterious",
        special_ability: "Star Jump",
        ability_description: "Can teleport between lily pads",
        favorite_food: "Moonlight moths",
        unique_trait: "Glows in the dark",
        backstory: "Born from a fallen star"
      })
    end
  end

  describe '#to_json' do
    let(:generated_frog) { described_class.new(**valid_attributes) }

    it 'returns JSON representation' do
      json = generated_frog.to_json
      parsed = JSON.parse(json)
      
      expect(parsed["name"]).to eq("Nebula")
      expect(parsed["species"]).to eq("Cosmic Tree Frog")
      expect(parsed["special_ability"]).to eq("Star Jump")
      expect(parsed["backstory"]).to eq("Born from a fallen star")
    end
  end

  describe '.from_json' do
    let(:json_data) { valid_attributes.to_json }

    it 'creates generated frog from JSON' do
      frog = described_class.from_json(json_data)
      
      expect(frog.name).to eq("Nebula")
      expect(frog.species).to eq("Cosmic Tree Frog")
      expect(frog.special_ability).to eq("Star Jump")
      expect(frog.backstory).to eq("Born from a fallen star")
    end
  end

  describe '.from_hash' do
    it 'creates generated frog from hash' do
      frog = described_class.from_hash(valid_attributes)
      
      expect(frog.name).to eq("Nebula")
      expect(frog.species).to eq("Cosmic Tree Frog")
      expect(frog.appearance).to eq("Iridescent purple skin with stars")
      expect(frog.personality).to eq("Wise and mysterious")
      expect(frog.special_ability).to eq("Star Jump")
      expect(frog.ability_description).to eq("Can teleport between lily pads")
      expect(frog.favorite_food).to eq("Moonlight moths")
      expect(frog.unique_trait).to eq("Glows in the dark")
      expect(frog.backstory).to eq("Born from a fallen star")
    end
  end
end