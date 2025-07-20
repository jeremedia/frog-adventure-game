# frozen_string_literal: true

require 'spec_helper'
require 'frog/adventure/web/models'

RSpec.describe Frog::Adventure::Web::Models::Frog do
  let(:valid_attributes) do
    {
      name: "Ribbit",
      frog_type: Frog::Adventure::Web::Models::FrogType::TREE_FROG,
      ability: "Climb anywhere",
      description: "A nimble green frog with sticky toe pads"
    }
  end

  describe '#initialize' do
    context 'with valid attributes' do
      it 'creates a frog with default values' do
        frog = described_class.new(**valid_attributes)
        
        expect(frog.name).to eq("Ribbit")
        expect(frog.frog_type).to eq("Tree Frog")
        expect(frog.ability).to eq("Climb anywhere")
        expect(frog.description).to eq("A nimble green frog with sticky toe pads")
        expect(frog.energy).to eq(100)
        expect(frog.happiness).to eq(50)
        expect(frog.items).to eq([])
        expect(frog.species).to eq("")
        expect(frog.personality).to eq("")
        expect(frog.backstory).to eq("")
      end

      it 'creates a frog with custom values' do
        attributes = valid_attributes.merge(
          energy: 80,
          happiness: 70,
          items: ["Magic Stone"],
          species: "Hyla arborea",
          personality: "Adventurous",
          backstory: "Once saved a village"
        )
        
        frog = described_class.new(**attributes)
        
        expect(frog.energy).to eq(80)
        expect(frog.happiness).to eq(70)
        expect(frog.items).to eq(["Magic Stone"])
        expect(frog.species).to eq("Hyla arborea")
        expect(frog.personality).to eq("Adventurous")
        expect(frog.backstory).to eq("Once saved a village")
      end
    end

    context 'with invalid attributes' do
      it 'raises error for empty name' do
        expect {
          described_class.new(**valid_attributes.merge(name: ""))
        }.to raise_error(ArgumentError, "Name cannot be empty")
      end

      it 'raises error for invalid frog type' do
        expect {
          described_class.new(**valid_attributes.merge(frog_type: "Invalid Type"))
        }.to raise_error(ArgumentError, "Invalid frog type: Invalid Type")
      end

      it 'raises error for empty ability' do
        expect {
          described_class.new(**valid_attributes.merge(ability: ""))
        }.to raise_error(ArgumentError, "Ability cannot be empty")
      end

      it 'raises error for empty description' do
        expect {
          described_class.new(**valid_attributes.merge(description: ""))
        }.to raise_error(ArgumentError, "Description cannot be empty")
      end

      it 'raises error for invalid energy' do
        expect {
          described_class.new(**valid_attributes.merge(energy: 150))
        }.to raise_error(ArgumentError, "Energy must be between 0 and 100")
      end

      it 'raises error for invalid happiness' do
        expect {
          described_class.new(**valid_attributes.merge(happiness: -10))
        }.to raise_error(ArgumentError, "Happiness must be between 0 and 100")
      end

      it 'raises error for non-array items' do
        expect {
          described_class.new(**valid_attributes.merge(items: "not an array"))
        }.to raise_error(ArgumentError, "Items must be an array")
      end
    end
  end

  describe '#custom?' do
    it 'returns true for custom frogs' do
      frog = described_class.new(**valid_attributes.merge(
        frog_type: Frog::Adventure::Web::Models::FrogType::CUSTOM
      ))
      expect(frog.custom?).to be true
    end

    it 'returns false for non-custom frogs' do
      frog = described_class.new(**valid_attributes)
      expect(frog.custom?).to be false
    end
  end

  describe '#display_type' do
    it 'returns species for custom frogs' do
      frog = described_class.new(**valid_attributes.merge(
        frog_type: Frog::Adventure::Web::Models::FrogType::CUSTOM,
        species: "Magical Pond Frog"
      ))
      expect(frog.display_type).to eq("Magical Pond Frog")
    end

    it 'returns frog_type for non-custom frogs' do
      frog = described_class.new(**valid_attributes)
      expect(frog.display_type).to eq("Tree Frog")
    end
  end

  describe '#add_item' do
    let(:frog) { described_class.new(**valid_attributes) }

    it 'adds new items' do
      frog.add_item("Magic Stone")
      expect(frog.items).to eq(["Magic Stone"])
      
      frog.add_item("Golden Leaf")
      expect(frog.items).to eq(["Magic Stone", "Golden Leaf"])
    end

    it 'does not add duplicate items' do
      frog.add_item("Magic Stone")
      frog.add_item("Magic Stone")
      expect(frog.items).to eq(["Magic Stone"])
    end
  end

  describe '#remove_item' do
    let(:frog) { described_class.new(**valid_attributes.merge(items: ["Magic Stone", "Golden Leaf"])) }

    it 'removes existing items' do
      frog.remove_item("Magic Stone")
      expect(frog.items).to eq(["Golden Leaf"])
    end

    it 'does nothing for non-existent items' do
      frog.remove_item("Non-existent")
      expect(frog.items).to eq(["Magic Stone", "Golden Leaf"])
    end
  end

  describe '#adjust_energy' do
    let(:frog) { described_class.new(**valid_attributes.merge(energy: 50)) }

    it 'increases energy within bounds' do
      frog.adjust_energy(20)
      expect(frog.energy).to eq(70)
    end

    it 'decreases energy within bounds' do
      frog.adjust_energy(-30)
      expect(frog.energy).to eq(20)
    end

    it 'caps energy at 100' do
      frog.adjust_energy(60)
      expect(frog.energy).to eq(100)
    end

    it 'caps energy at 0' do
      frog.adjust_energy(-60)
      expect(frog.energy).to eq(0)
    end
  end

  describe '#adjust_happiness' do
    let(:frog) { described_class.new(**valid_attributes.merge(happiness: 50)) }

    it 'increases happiness within bounds' do
      frog.adjust_happiness(20)
      expect(frog.happiness).to eq(70)
    end

    it 'decreases happiness within bounds' do
      frog.adjust_happiness(-30)
      expect(frog.happiness).to eq(20)
    end

    it 'caps happiness at 100' do
      frog.adjust_happiness(60)
      expect(frog.happiness).to eq(100)
    end

    it 'caps happiness at 0' do
      frog.adjust_happiness(-60)
      expect(frog.happiness).to eq(0)
    end
  end

  describe '#tired?' do
    it 'returns true when energy < 20' do
      frog = described_class.new(**valid_attributes.merge(energy: 15))
      expect(frog.tired?).to be true
    end

    it 'returns false when energy >= 20' do
      frog = described_class.new(**valid_attributes.merge(energy: 20))
      expect(frog.tired?).to be false
    end
  end

  describe '#happy?' do
    it 'returns true when happiness > 70' do
      frog = described_class.new(**valid_attributes.merge(happiness: 80))
      expect(frog.happy?).to be true
    end

    it 'returns false when happiness <= 70' do
      frog = described_class.new(**valid_attributes.merge(happiness: 70))
      expect(frog.happy?).to be false
    end
  end

  describe '#sad?' do
    it 'returns true when happiness < 30' do
      frog = described_class.new(**valid_attributes.merge(happiness: 20))
      expect(frog.sad?).to be true
    end

    it 'returns false when happiness >= 30' do
      frog = described_class.new(**valid_attributes.merge(happiness: 30))
      expect(frog.sad?).to be false
    end
  end

  describe '#to_h' do
    let(:frog) { described_class.new(**valid_attributes) }

    it 'returns hash representation' do
      hash = frog.to_h
      
      expect(hash).to eq({
        name: "Ribbit",
        type: "Tree Frog",
        ability: "Climb anywhere",
        description: "A nimble green frog with sticky toe pads",
        energy: 100,
        happiness: 50,
        items: [],
        species: "",
        personality: "",
        backstory: ""
      })
    end
  end

  describe '#to_json' do
    let(:frog) { described_class.new(**valid_attributes) }

    it 'returns JSON representation' do
      json = frog.to_json
      parsed = JSON.parse(json)
      
      expect(parsed["name"]).to eq("Ribbit")
      expect(parsed["type"]).to eq("Tree Frog")
      expect(parsed["ability"]).to eq("Climb anywhere")
      expect(parsed["energy"]).to eq(100)
    end
  end

  describe '.from_json' do
    let(:json_data) do
      {
        name: "Hoppy",
        type: "Bullfrog",
        ability: "Powerful leap",
        description: "A strong frog",
        energy: 80,
        happiness: 60,
        items: ["Stone"],
        species: "American Bullfrog",
        personality: "Bold",
        backstory: "Champion leaper"
      }.to_json
    end

    it 'creates frog from JSON' do
      frog = described_class.from_json(json_data)
      
      expect(frog.name).to eq("Hoppy")
      expect(frog.frog_type).to eq("Bullfrog")
      expect(frog.ability).to eq("Powerful leap")
      expect(frog.energy).to eq(80)
      expect(frog.items).to eq(["Stone"])
    end
  end

  describe '.from_hash' do
    let(:hash_data) do
      {
        name: "Splash",
        type: "Glass Frog",
        ability: "Near invisibility",
        description: "A translucent frog",
        energy: 90,
        happiness: 55,
        items: ["Crystal"],
        species: "Hyalinobatrachium",
        personality: "Mysterious",
        backstory: "Guardian of secrets"
      }
    end

    it 'creates frog from hash' do
      frog = described_class.from_hash(hash_data)
      
      expect(frog.name).to eq("Splash")
      expect(frog.frog_type).to eq("Glass Frog")
      expect(frog.ability).to eq("Near invisibility")
      expect(frog.energy).to eq(90)
    end

    it 'handles frog_type key instead of type' do
      data = hash_data.dup
      data[:frog_type] = data.delete(:type)
      
      frog = described_class.from_hash(data)
      expect(frog.frog_type).to eq("Glass Frog")
    end
  end
end