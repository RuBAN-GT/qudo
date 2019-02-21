# frozen_string_literal: true

require 'qudo/object_factory'

RSpec.describe Qudo::ObjectFactory do
  def child_factory
    Class.new described_class
  end

  def full_factory
    child_factory.tap do |f|
      f.builder { [Faker::Number.number] }
    end
  end

  def factory_instance_with_target
    target  = Faker::Number.number
    factory = child_factory.tap do |f|
      f.builder { target }
      f.finalizer manual: true
    end

    [factory.new, target]
  end

  describe '#build' do
    it 'raises on undefined builder' do
      sample_factory_instance = child_factory.new
      expect { sample_factory_instance.build }.to raise_error LoadError
    end

    it 'creates target after build process' do
      factory_instance, target = factory_instance_with_target

      expect { factory_instance.build }.not_to raise_error
      expect(factory_instance.target).to eq(target)
    end

    it 'sets flag built after successfully building' do
      factory_instance = full_factory.new.tap(&:build)
      expect(factory_instance.built?).to be_truthy
    end

    it 'calls related :before_build, :after_build hooks' do
      factory_instance = full_factory.new

      expect(factory_instance).to receive(:run_hook).with(:before_build)
      expect(factory_instance).to receive(:run_hook).with(:after_build)
      factory_instance.build
    end
  end

  describe '#finalize' do
    it 'resets value of built target' do
      factory_instance = full_factory.new.tap(&:build)

      expect(factory_instance.target).not_to be_nil
      expect { factory_instance.finalize }.not_to raise_error
      expect(factory_instance.target).to be_nil
    end

    it 'calls finalizer with removed target' do
      target  = [Faker::Number.number]
      dbl     = double(destructor: nil)
      factory = child_factory.tap do |f|
        f.builder   { target }
        f.finalizer { |*args| dbl.destructor(*args) }
      end

      expect(dbl).to receive(:destructor).with(target)
      factory.new.tap(&:build).tap(&:finalize)
    end

    it 'doesnt start finalization for not built object' do
      factory_instance = full_factory.new

      expect(factory_instance.built?).to be_falsey
      expect(factory_instance).not_to receive(:reset_target)
      expect { factory_instance.finalize }.not_to raise_error
    end

    it 'calls related :before_finalize, :after_finalize hooks' do
      factory_instance = full_factory.new.tap(&:build)

      expect(factory_instance).to receive(:run_hook).with(:before_finalize)
      expect(factory_instance).to receive(:run_hook).with(:after_finalize)
      factory_instance.finalize
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
        factory = full_factory.tap do |f|
          f.finalizer do |_|
            wr.write sample
            wr.close
          end
        end

        factory_instance = factory.new.tap(&:build)
        factory_instance.instance_variable_set :@target, nil

        GC.start
      end
    end
  end

  describe '#resolve' do
    it 'creates and returns a new target if it is not built yet' do
      factory_instance, target = factory_instance_with_target

      expect(factory_instance.built?).to be_falsey
      expect(factory_instance.resolve).to be target
      expect(factory_instance.built?).to be_truthy
    end

    it 'returns existed target if it exists' do
      factory_instance, target = factory_instance_with_target
      factory_instance.build

      allow(factory_instance).to receive(:build)

      expect(factory_instance.built?).to be_truthy
      expect(factory_instance.resolve).to be target
      expect(factory_instance).not_to have_received(:build)
    end
  end
end
