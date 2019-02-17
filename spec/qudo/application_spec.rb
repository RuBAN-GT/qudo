# frozen_string_literal: true

require 'qudo/application'
require 'qudo/container'
require 'qudo/utils'
require 'qudo/utils/persistent_store'

RSpec.describe Qudo::Application do
  STORE_CLASS = Qudo::Utils::PersistentStore
  DEFAULT_CONTAINER = Qudo::Application::DEFAULT_CONTAINER

  subject { Class.new described_class }

  describe '.config' do
    it 'has persistent store for configuration' do
      expect(subject.config).to be_a STORE_CLASS
    end
  end

  describe '.containers' do
    it 'has persistent store of containers' do
      expect(subject.containers).to be_a STORE_CLASS
    end

    it 'has default container' do
      expect(subject.containers[DEFAULT_CONTAINER]).to be_a Qudo::Container
      expect(subject.container).to be_a Qudo::Container
      expect(subject.container).to be subject.containers[DEFAULT_CONTAINER]
    end
  end

  describe '.boot' do
    context 'when path is undefined' do
      it 'raises if path of application is unknown' do
        expect { subject.boot }.to raise_error LoadError
      end
    end

    context 'when all settings is filled' do
      let(:application_path) do
        Faker::File.file_name
      end

      subject do
        app_path = application_path
        Class.new(described_class) do
          path app_path
        end
      end

      it 'changes boot status after successfully booting' do
        expect(subject.booted?).to be_falsey
        subject.boot
        expect(subject.booted?).to be_truthy
      end

      it 'requires internal rb files of application' do
        expect(Qudo::Utils).to receive(:recursive_require) do |dir, mask|
          expect(dir.to_s).to eq application_path
          expect(mask).to be_nil
        end
        expect { subject.boot }.not_to raise_error
      end

      it 'returns nil for already loaded application' do
        subject.boot
        expect(subject.boot).to be_nil
      end
    end
  end

  describe '.boot!' do
    subject do
      Class.new(described_class) { path __dir__ }
    end

    it 'raises LoadError for already loaded application' do
      subject.boot!
      expect { subject.boot! }.to raise_error LoadError
    end
  end
end
