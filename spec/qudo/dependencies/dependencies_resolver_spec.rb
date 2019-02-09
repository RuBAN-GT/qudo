# frozen_string_literal: true

require 'hashie'
require 'ostruct'
require 'qudo/dependencies/dependencies_resolver'

RSpec.describe Qudo::Dependencies::DependenciesResolver do
  subject { Qudo::Dependencies::DependenciesResolver }

  def fake_key
    Faker::Lorem.word
  end

  def fake_requirements
    Array.new(rand(1..100)) { fake_key }.uniq
  end

  def fake_dependencies(keys)
    keys.each_with_object(Hashie::Mash.new) { |key, total| total[key] = proc {} }
  end

  describe '.retrieve_dependency' do
    it 'raises ArgumentError for non-existed dependency' do
      expect { described_class.retrieve_dependency({}, fake_key) }.to raise_error ArgumentError
    end

    it 'returns existed dependency by key' do
      sample_key   = fake_key
      sample_dep   = proc {}
      dependencies = { sample_key => sample_dep }

      retrieved = described_class.retrieve_dependency(dependencies, sample_key)
      expect(retrieved).to be(sample_dep)
    end
  end

  describe '.retrieve' do
    it 'returns immutable hash with retrieved dependencies from manager' do
      requirements = fake_requirements
      dependencies = fake_dependencies requirements

      expect(described_class).to receive(:retrieve_dependency).exactly(requirements.length).times

      retrieved = described_class.retrieve dependencies, requirements
      expect(retrieved).to be_a Hash
      expect(retrieved).to include(*requirements)
      expect(retrieved.frozen?).to be_truthy
    end
  end

  describe '.resolve_dependency' do
    it 'resolves dependency with #resolve if it is possible' do
      value      = Faker::Number.number
      dependency = OpenStruct.new(resolve: value)

      expect(described_class.resolve_dependency(dependency)).to be value
    end

    it 'resolves dependency with #call if it is possible' do
      value      = Faker::Number.number
      dependency = proc { value }

      expect(described_class.resolve_dependency(dependency)).to be value
    end

    it 'resolved with #resolve and ignore #call method' do
      value      = Faker::Number.number.to_i
      dependency = OpenStruct.new(call: value + 1, resolve: value)

      expect(described_class.resolve_dependency(dependency)).to be value
    end

    it 'raises ArgumentError for unknown dependence' do
      expect { described_class.resolve_dependency(OpenStruct.new) }.to raise_error ArgumentError
    end
  end

  describe '.resolve' do
    it 'returns immutable hash with resolved dependencies' do
      requirements = fake_requirements
      dependencies = fake_dependencies requirements

      expect(described_class).to receive(:resolve_dependency).exactly(requirements.length).times

      resolved = described_class.resolve dependencies, requirements
      expect(resolved).to be_a Hash
      expect(resolved).to include(*requirements)
      expect(resolved.frozen?).to be_truthy
    end
  end
end
