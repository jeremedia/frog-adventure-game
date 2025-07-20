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
        expect(frog.stats).to be_a(Hash)
        expect(frog.stats.keys).to contain_exactly(:strength, :agility, :intelligence, :magic, :luck)
        expect(frog.traits).to be_an(Array)
        expect(frog.traits.length).to be_between(2, 3)
        expect(frog.ability_cooldown).to eq(0)
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
      
      expect(hash[:name]).to eq("Ribbit")
      expect(hash[:type]).to eq("Tree Frog")
      expect(hash[:ability]).to eq("Climb anywhere")
      expect(hash[:description]).to eq("A nimble green frog with sticky toe pads")
      expect(hash[:energy]).to eq(100)
      expect(hash[:happiness]).to eq(50)
      expect(hash[:items]).to eq([])
      expect(hash[:species]).to eq("")
      expect(hash[:personality]).to eq("")
      expect(hash[:backstory]).to eq("")
      expect(hash[:stats]).to be_a(Hash)
      expect(hash[:traits]).to be_an(Array)
      expect(hash[:ability_cooldown]).to eq(0)
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

  describe 'stats system' do
    let(:frog) { described_class.new(**valid_attributes) }

    describe '#stats' do
      it 'generates stats based on frog type' do
        tree_frog = described_class.new(**valid_attributes.merge(frog_type: Frog::Adventure::Web::Models::FrogType::TREE_FROG))
        expect(tree_frog.stats[:agility]).to be >= 12  # Tree frogs should have high agility base
        
        bullfrog = described_class.new(**valid_attributes.merge(frog_type: Frog::Adventure::Web::Models::FrogType::BULLFROG))
        expect(bullfrog.stats[:strength]).to be >= 15  # Bullfrogs should have high strength base
      end

      it 'keeps all stats within valid range' do
        frog.stats.each do |stat, value|
          expect(value).to be_between(5, 20)
        end
      end

      it 'prevents total stats from being too high' do
        expect(frog.total_stats).to be <= 85
      end
    end

    describe '#traits' do
      it 'generates 2-3 personality traits' do
        expect(frog.traits.length).to be_between(2, 3)
      end

      it 'does not include contradictory traits' do
        contradictory_pairs = [
          ["Brave", "Cautious"], ["Friendly", "Grumpy"], ["Energetic", "Lazy"],
          ["Optimistic", "Pessimistic"], ["Patient", "Impulsive"]
        ]
        
        contradictory_pairs.each do |pair|
          if frog.traits.include?(pair[0])
            expect(frog.traits).not_to include(pair[1])
          end
        end
      end
    end

    describe '#ability_power' do
      it 'calculates ability power based on magic stat' do
        power = frog.ability_power
        expected_power = 10 * (1 + frog.stats[:magic] / 20.0)
        expect(power).to be_within(0.1).of(expected_power)
      end
    end

    describe '#can_use_ability?' do
      it 'returns true when ability is off cooldown' do
        frog.ability_cooldown = 0
        expect(frog.can_use_ability?).to be true
      end

      it 'returns false when ability is on cooldown' do
        frog.ability_cooldown = 2
        expect(frog.can_use_ability?).to be false
      end
    end

    describe '#use_ability!' do
      it 'returns true and sets cooldown when ability can be used' do
        frog.ability_cooldown = 0
        result = frog.use_ability!
        
        expect(result).to be true
        expect(frog.ability_cooldown).to eq(3)
      end

      it 'returns false when ability is on cooldown' do
        frog.ability_cooldown = 2
        result = frog.use_ability!
        
        expect(result).to be false
        expect(frog.ability_cooldown).to eq(2)  # Unchanged
      end
    end

    describe '#reduce_cooldown!' do
      it 'reduces cooldown by 1' do
        frog.ability_cooldown = 3
        frog.reduce_cooldown!
        expect(frog.ability_cooldown).to eq(2)
      end

      it 'does not go below 0' do
        frog.ability_cooldown = 0
        frog.reduce_cooldown!
        expect(frog.ability_cooldown).to eq(0)
      end
    end
  end

  describe 'validation' do
    it 'raises error for invalid stats hash' do
      expect {
        described_class.new(**valid_attributes, stats: "not a hash")
      }.to raise_error(ArgumentError, "Stats must be a hash")
    end

    it 'raises error for invalid traits array' do
      expect {
        described_class.new(**valid_attributes, traits: "not an array")
      }.to raise_error(ArgumentError, "Traits must be an array")
    end

    it 'raises error for negative ability cooldown' do
      expect {
        described_class.new(**valid_attributes, ability_cooldown: -1)
      }.to raise_error(ArgumentError, "Ability cooldown must be non-negative")
    end

    it 'raises error for missing stats' do
      incomplete_stats = { strength: 10, agility: 10 }  # Missing magic, intelligence, luck
      expect {
        described_class.new(**valid_attributes, stats: incomplete_stats)
      }.to raise_error(ArgumentError, /Missing required stat/)
    end

    it 'raises error for stats out of range' do
      invalid_stats = { strength: 25, agility: 10, intelligence: 10, magic: 10, luck: 10 }
      expect {
        described_class.new(**valid_attributes, stats: invalid_stats)
      }.to raise_error(ArgumentError, /must be between 5 and 20/)
    end

    it 'raises error for total stats too high' do
      overpowered_stats = { strength: 20, agility: 20, intelligence: 20, magic: 20, luck: 20 }
      expect {
        described_class.new(**valid_attributes, stats: overpowered_stats)
      }.to raise_error(ArgumentError, /Total stats too high/)
    end
  end
end