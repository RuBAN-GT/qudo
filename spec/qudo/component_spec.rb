# frozen_string_literal: true

require 'qudo/component'

RSpec.describe Qudo::Component do
  subject do
    Class.new(described_class) do
      def self.builder(*_)
        Faker::Number.number
      end
    end
  end

  def component_config
    proc do |s|
      s.property :username, required: true, default: 'admin'
      s.property :password, required: true
    end
  end

  def component_with_config
    subject.tap { |comp| comp.config(&component_config) }
  end

  describe '.new' do
    it 'creates component instance with passed config' do
      sample   = component_with_config
      password = Faker::Internet.password
      object   = double

      expect { object = sample.new(password: password) }.not_to raise_error
      expect(object.config.password).to eq(password)
    end

    it 'creates component instance with default config object on undefined config' do
      object = double

      expect { object = subject.new(password: Faker::Internet.password) }.not_to raise_error
      expect(object.config.class.superclass).to be(subject.default_config.superclass)
      expect(object.config.values.length).to be(0)
    end
  end

  describe '#build_args' do
    it 'returns builder arguments with config and resolved dependencies' do
      sample = subject.new

      allow(sample).to receive(:config) { :config }
      allow(sample).to receive(:resolve_dependencies) { :deps }

      expect(sample.build_args).to eq %i[config deps]
    end
  end
end
