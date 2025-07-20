# frozen_string_literal: true

require 'spec_helper'
require 'frog/adventure/web/models/frog_personality'

RSpec.describe Frog::Adventure::Web::Models::FrogPersonality do
  describe 'constants' do
    it 'defines all frog personalities' do
      expect(described_class::ADVENTUROUS).to eq("Adventurous")
      expect(described_class::WISE).to eq("Wise")
      expect(described_class::PLAYFUL).to eq("Playful")
      expect(described_class::MYSTERIOUS).to eq("Mysterious")
      expect(described_class::BRAVE).to eq("Brave")
      expect(described_class::CURIOUS).to eq("Curious")
      expect(described_class::GRUMPY).to eq("Grumpy")
      expect(described_class::CHEERFUL).to eq("Cheerful")
    end

    it 'has ALL constant with all frog personalities' do
      expect(described_class::ALL).to be_frozen
      expect(described_class::ALL).to contain_exactly(
        "Adventurous", "Wise", "Playful", "Mysterious",
        "Brave", "Curious", "Grumpy", "Cheerful"
      )
    end
  end

  describe '.valid?' do
    it 'returns true for valid frog personalities' do
      described_class::ALL.each do |personality|
        expect(described_class.valid?(personality)).to be true
      end
    end

    it 'returns false for invalid frog personalities' do
      expect(described_class.valid?("Invalid Personality")).to be false
      expect(described_class.valid?("")).to be false
      expect(described_class.valid?(nil)).to be false
    end
  end

  describe '.random' do
    it 'returns a random frog personality from ALL' do
      100.times do
        random_personality = described_class.random
        expect(described_class::ALL).to include(random_personality)
      end
    end

    it 'returns different personalities over multiple calls' do
      personalities = 50.times.map { described_class.random }.uniq
      expect(personalities.size).to be > 1
    end
  end
end