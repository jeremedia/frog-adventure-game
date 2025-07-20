# frozen_string_literal: true

require 'spec_helper'
require 'frog/adventure/web/models/frog_type'

RSpec.describe Frog::Adventure::Web::Models::FrogType do
  describe 'constants' do
    it 'defines all frog types' do
      expect(described_class::TREE_FROG).to eq("Tree Frog")
      expect(described_class::POISON_DART_FROG).to eq("Poison Dart Frog")
      expect(described_class::BULLFROG).to eq("Bullfrog")
      expect(described_class::GLASS_FROG).to eq("Glass Frog")
      expect(described_class::ROCKET_FROG).to eq("Rocket Frog")
      expect(described_class::RAIN_FROG).to eq("Rain Frog")
      expect(described_class::CUSTOM).to eq("Custom")
    end

    it 'has ALL constant with all frog types' do
      expect(described_class::ALL).to be_frozen
      expect(described_class::ALL).to contain_exactly(
        "Tree Frog", "Poison Dart Frog", "Bullfrog", 
        "Glass Frog", "Rocket Frog", "Rain Frog", "Custom"
      )
    end
  end

  describe '.valid?' do
    it 'returns true for valid frog types' do
      described_class::ALL.each do |frog_type|
        expect(described_class.valid?(frog_type)).to be true
      end
    end

    it 'returns false for invalid frog types' do
      expect(described_class.valid?("Invalid Frog")).to be false
      expect(described_class.valid?("")).to be false
      expect(described_class.valid?(nil)).to be false
    end
  end

  describe '.random' do
    it 'returns a random frog type from ALL' do
      100.times do
        random_type = described_class.random
        expect(described_class::ALL).to include(random_type)
      end
    end

    it 'returns different types over multiple calls' do
      types = 50.times.map { described_class.random }.uniq
      expect(types.size).to be > 1
    end
  end
end