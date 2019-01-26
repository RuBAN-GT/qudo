# frozen_string_literal: true

require 'qudo/types'
require 'qudo/utils/config_builder'

RSpec.describe Qudo::Utils::ConfigBuilder do
  def sample_class
    Class.new { extend Qudo::Utils::ConfigBuilder }
  end

  def sample_config
    proc do
      attribute :username, Qudo::Types::Strict::String.default('admin')
      attribute :password, Qudo::Types::Strict::String
    end
  end

  def sample_with_config
    sample_class.tap do |comp|
      comp.config(&sample_config)
    end
  end

  describe '.config' do
    it 'setup a class configuration' do
      expect { sample_class.config sample_config }.not_to raise_error
      expect { sample_class.config(&sample_config) }.not_to raise_error
    end
  end

  describe '.build_config' do
    context 'when config is undefined' do
      it 'creates default config object' do
        sample = sample_class
        object = double

        expect { object = sample.build_config }.not_to raise_error
        expect(object.class.superclass).to be(sample.default_config.superclass)
        expect(object.attributes.length).to be(0)
      end

      it 'creates config object without attributes' do
        sample = sample_class
        object = double

        expect { object = sample.build_config(something: Faker::Number.number) }.not_to raise_error
        expect(object.attributes).not_to include(:something)
        expect(object.attributes.length).to be(0)
      end
    end

    context 'when config is setting up' do
      it 'creates config object with attributes from config scheme' do
        sample = sample_with_config

        password = Faker::Internet.password
        object   = double

        expect { object = sample.build_config(password: password, special: true) }.not_to raise_error
        expect(object.attributes).to include(:username, :password)
        expect(object.attributes).not_to include(:special)
        expect(object.username).to eq('admin')
        expect(object.password).to eq(password)
      end
    end
  end
end
