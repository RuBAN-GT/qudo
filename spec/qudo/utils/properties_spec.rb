# frozen_string_literal: true

require 'qudo/utils/properties'

RSpec.describe Qudo::Utils::Properties do
  subject do
    described_module = described_class
    Class.new { include described_module }
  end

  describe '.property' do
    it 'adds scalar property to store' do
      sample = Faker::Lorem.word
      subject.property :prop_key, sample

      expect(subject.properties[:prop_key]).to be sample
    end

    it 'updates existed property' do
      sample = rand(1..100)
      subject.property(:prop_key, sample)
      expect(subject.properties[:prop_key]).to be(sample)

      subject.property(:prop_key, sample + 1)
      expect(subject.properties[:prop_key]).to be(sample + 1)
    end

    it 'returns property value' do
      subject.property :prop_key, 42

      expect(subject.properties[:prop_key]).to be 42
      expect(subject.property(:prop_key)).to be 42
    end

    it 'returns nil for non-existed property' do
      expect(subject.property(Faker::Lorem.word)).to be_nil
      expect(subject.properties[Faker::Lorem.word]).to be_nil
    end

    context 'when property is proc/lambda' do
      it 'adds property and doesnt call them' do
        input = double call: 0

        expect(input).not_to receive :call

        subject.property :sample, input
        expect(subject.properties[:sample]).to be input
      end

      it 'returns property value from proc and saves them' do
        value = Faker::Lorem.word
        input = proc { value }

        expect(input).to receive(:call) { value }

        subject.property :sample, input

        expect(subject.property(:sample)).to be value
        expect(subject.properties[:sample]).to be value
      end
    end
  end

  describe '.properties' do
    it 'returns non frozen properties' do
      expect(subject.properties.frozen?).to be_falsey
    end
  end

  describe '#initialize' do
    it 'fills @properties from freeze duped properties' do
      inst = subject.new

      expect(inst.properties.frozen?).to be_truthy
      expect(inst.properties).to include subject.properties
      expect(inst.properties).not_to be subject.properties
    end

    context 'when class has own initializer' do
      subject do
        described_module = described_class
        Class.new do
          include described_module

          attr_reader :sample

          def initialize
            @sample = Faker::Lorem.word
          end
        end
      end

      it 'doesnt break original class initializer' do
        inst = subject.new

        expect(inst.sample).not_to be_nil
        expect(inst.properties).to include subject.properties
      end
    end
  end
end
