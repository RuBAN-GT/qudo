# frozen_string_literal: true

require 'qudo/application'
require 'qudo/container'
require 'qudo/utils/persistent_store'

RSpec.describe Qudo::Application do
  STORE_CLASS = Qudo::Utils::PersistentStore

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

    context 'when has containers' do
      subject do
        Class.new(described_class) do
          containers[:default] = Qudo::Container.new
        end
      end

      it 'has default container from list' do
        expect(subject.containers[:default]).to be_a Qudo::Container
        expect(subject.container).to be_a Qudo::Container
        expect(subject.container).to be subject.containers[:default]
      end
    end

    context "when hasn't containers" do
      it 'returns empty store for containers' do
        expect(subject.containers.values.length).to be 0
      end

      it 'returns nil for default container' do
        expect(subject.containers[:default]).to be_nil
        expect(subject.container).to be_nil
      end
    end
  end
end
