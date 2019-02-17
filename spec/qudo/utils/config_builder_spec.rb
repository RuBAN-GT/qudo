# frozen_string_literal: true

require 'qudo/utils/config_builder'

RSpec.describe Qudo::Utils::ConfigBuilder do
  subject do
    Class.new { extend Qudo::Utils::ConfigBuilder }
  end

  def sample_config
    proc do |s|
      s.property :username, required: true, default: 'admin'
      s.property :password, required: true
    end
  end

  def sample_with_config
    subject.tap { |comp| comp.config(&sample_config) }
  end

  describe '.config' do
    it 'setup a class configuration' do
      expect { subject.config sample_config }.not_to raise_error
      expect { subject.config(&sample_config) }.not_to raise_error
    end
  end

  describe '.build_config' do
    context 'when config is undefined' do
      it 'creates default config object' do
        object = double

        expect { object = subject.build_config }.not_to raise_error
        expect(object.class.superclass).to be(subject.default_config.superclass)
        expect(object.values.length).to be(0)
      end

      it 'creates config object without attributes' do
        object = double

        expect { object = subject.build_config(something: Faker::Number.number) }.not_to raise_error
        expect(object.values).not_to include(:something)
        expect(object.values.length).to be(0)
      end
    end

    context 'when config is setting up' do
      it 'creates config object with attributes from config scheme' do
        sample   = sample_with_config
        password = Faker::Internet.password
        object   = double

        expect { object = sample.build_config(password: password, special: true) }.not_to raise_error
        expect(object.keys).to include(:username, :password)
        expect(object.keys).not_to include(:special)
        expect(object.username).to eq('admin')
        expect(object.password).to eq(password)
      end
    end
  end
end
