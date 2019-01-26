# frozen_string_literal: true

require 'qudo/component'

RSpec.describe Qudo::Component do
  def component_class
    Class.new(described_class) { builder { [Faker::Number.number] } }
  end

  def component_config
    proc do
      attribute :username, Qudo::Types::Strict::String.default('admin')
      attribute :password, Qudo::Types::Strict::String
    end
  end

  def component_with_config
    component_class.tap do |comp|
      comp.config(&component_config)
    end
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
      sample = component_class
      object = double

      expect { object = sample.new(password: Faker::Internet.password) }.not_to raise_error
      expect(object.config.class.superclass).to be(sample.default_config.superclass)
      expect(object.config.attributes.length).to be(0)
    end
  end
end
