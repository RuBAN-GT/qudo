# frozen_string_literal: true

require 'qudo/utils/config'
require 'hashie'

RSpec.describe Qudo::Utils::Config do
  subject do
    Class.new(described_class) do
      property :prop, required: true
    end
  end

  describe '.properties' do
    it 'supports another configs' do
      value  = Faker::RickAndMorty.character
      sample = nil
      config = subject.new prop: value

      expect { sample = subject.new config }.not_to raise_error
      expect(sample.prop).to be value
    end

    it 'supports Mash instances in initialization' do
      value  = Faker::RickAndMorty.character
      sample = nil

      init_cfg = Hashie::Mash.new prop: value
      expect { sample = subject.new init_cfg }.not_to raise_error
      expect(sample.prop).to be value

      mutated_cfg = Hashie::Mash.new
      mutated_cfg.prop = value

      expect { sample = subject.new mutated_cfg }.not_to raise_error
      expect(sample.prop).to be value
    end
  end

  describe '#[]' do
    it 'works similar with hashes with symbol or string keys' do
      [:prop, 'prop'].each do |key|
        value  = Faker::RickAndMorty.character
        sample = nil

        expect { sample = subject.new prop: value }.not_to raise_error
        expect(sample[key.to_s]).to be value
        expect(sample[key.to_sym]).to be value
        expect(sample.send(key)).to be value
      end
    end
  end

  describe '#[]=' do
    it 'works similar with hashes with symbol or string keys' do
      [:prop, 'prop'].each do |key|
        sample = subject.new prop: Faker::Lorem.word
        value  = Faker::ChuckNorris.fact

        sample[key] = value

        expect(sample[key.to_s]).to be value
        expect(sample[key.to_sym]).to be value
      end
    end
  end
end
