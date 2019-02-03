# frozen_string_literal: true

require 'qudo/object_factory'

RSpec.describe Qudo::ObjectFactory do
  def child_factory
    Class.new described_class
  end

  def full_factory
    factory = child_factory
    factory.builder { [Faker::Number.number] }

    factory
  end

  describe '#build' do
    it 'raises on undefined builder' do
      sample_factory_instance = child_factory.new
      expect { sample_factory_instance.build }.to raise_error(/Undefined/)
    end

    it 'creates target on build process' do
      sample_target  = Faker::Number.number
      sample_factory = child_factory
      sample_factory.builder { sample_target }
      sample_factory.finalizer manual: true

      sample_factory_instance = sample_factory.new

      expect { sample_factory_instance.build }.not_to raise_error
      expect(sample_factory_instance.target).to eq(sample_target)
    end

    it 'sets flag built after successfull building' do
      sample_factory = full_factory
      sample_factory_instance = sample_factory.new
      sample_factory_instance.build

      expect(sample_factory_instance.built?).to be_truthy
    end

    it 'calls #handle_finalizer for target on build process' do
      sample_factory = full_factory
      sample_factory_instance = sample_factory.new

      allow(sample_factory_instance).to receive(:handle_finalizer)
      sample_factory_instance.build
      expect(sample_factory_instance).to have_received(:handle_finalizer)
    end
  end

  describe '#finalize' do
    it 'resets target manually on finalization process' do
      sample_factory = full_factory
      sample_factory_instance = sample_factory.new
      sample_factory_instance.build

      expect { sample_factory_instance.finalize }.not_to raise_error
      expect(sample_factory_instance.target).to be_nil
    end

    it 'calls original finailizer on #finalize' do
      dbl = double(destructor: nil)
      expect(dbl).to receive(:destructor)

      sample_factory = full_factory
      sample_factory.finalizer { |_| dbl.destructor }

      sample_factory_instance = sample_factory.new
      sample_factory_instance.build

      expect { sample_factory_instance.finalize }.not_to raise_error
    end
  end

  describe '#bind_finalizer' do
    it 'binds #finailize to a target in unmanual mode' do
      sample = Faker::String.random
      rd, wr = IO.pipe

      if fork
        wr.close
        called = rd.read
        Process.wait

        expect(called).to eq(sample)
        rd.close
      else
        sample_factory = full_factory
        sample_factory.finalizer do |_|
          wr.write sample
          wr.close
        end

        sample_factory_instance = sample_factory.new
        sample_factory_instance.build
        sample_factory_instance.instance_variable_set :@target, nil

        GC.start
      end
    end
  end

  describe '#resolve' do
    it 'creates new target if it is not built yet' do
      sample_factory = full_factory
      sample_factory_instance = sample_factory.new

      allow(sample_factory_instance).to receive(:build)
      expect { sample_factory_instance.resolve }.not_to raise_error
      expect(sample_factory_instance).to have_received(:build)
    end

    it 'returns existed target if it exists' do
      sample_factory = full_factory
      sample_factory_instance = sample_factory.new
      sample_factory_instance.build

      allow(sample_factory_instance).to receive_messages(build: nil, target: nil)
      expect { sample_factory_instance.resolve }.not_to raise_error

      expect(sample_factory_instance).not_to have_received(:build)
      expect(sample_factory_instance).to have_received(:target)
    end
  end
end
