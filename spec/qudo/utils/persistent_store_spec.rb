# frozen_string_literal: true

require 'qudo/utils/persistent_store'

RSpec.describe Qudo::Utils::PersistentStore do
  subject { described_class.new }

  describe '#[]=' do
    it 'allow to set value firstly' do
      some_key   = Faker::Lorem.word
      some_value = Faker::Pokemon.name

      expect { subject[some_key] = some_value }.not_to raise_error
      expect(subject[some_key]).to be some_value
    end

    it 'raises on repeated a key filling' do
      some_key   = Faker::Lorem.word
      some_value = rand(1..100)

      expect { subject[some_key] = some_value }.not_to raise_error
      expect { subject[some_key] = some_value + 1 }.to raise_error ArgumentError
    end
  end
end
