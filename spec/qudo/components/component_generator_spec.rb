# frozen_string_literal: true

require 'qudo/components/component_generator'

RSpec.describe Qudo::Components::ComponentGenerator do
  describe '#register' do
    context 'when push component class and options' do
      it 'raises error for class without included DependenciesBuilder' do
        sample_class = Class.new Qudo::ObjectFactory
        expect { subject.register :some_key, sample_class }.to raise_error ArgumentError
      end

      it 'creates class instance from correct input' do
        register_key = Faker::Lorem.word
        subject.register register_key, input_class

        expect(subject.retrieve(register_key)).to be_a input_class
      end

      it 'creates class instance with merged options and dependencies' do
        input_options = { Faker::Lorem.word => Faker::Number.number }
        expect(input_class).to receive(:new) do |args|
          expect(args).to be_a Hash
          expect(args).to include input_options
          expect(args).to include(dependencies: subject.components)
        end

        subject.register :some_key, input_class, input_options
      end
    end

    context 'when push component instance' do
      it 'raises error for class instance without DependenciesBuilder' do
        sample_class = Class.new Qudo::ObjectFactory
        expect { subject.register :some_key, sample_class.new }.to raise_error ArgumentError
      end

      it 'pushes a original component' do
        register_key = Faker::Lorem.word
        subject.register register_key, input_instance

        expect(subject.retrieve(register_key)).to be input_instance
      end

      it 'injects dependencies to unresolved component' do
        expect(input_instance).to receive(:inject_dependencies) do |args|
          expect(args).to include(subject.components)
        end

        subject.register :some_key, input_instance
      end

      it 'doesnt inject dependencies for resolved component' do
        expect(input_instance).not_to receive(:inject_dependencies)

        input_instance.resolve
        subject.register :some_key, input_instance
      end
    end
  end
end
