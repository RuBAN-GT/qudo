# frozen_string_literal: true

require 'qudo/utils/class_loader'

RSpec.describe Qudo::Utils::ClassLoader do
  subject { described_class }

  describe '.load_list' do
    it 'loads classes from path and returns their definitions' do
      entities = subject.load_list RSpec.spec_path.join('samples', 'components', '**', '*.rb')

      expect(entities).to be_a Array
      expect(entities).to include Sample0, A::Sample1, A::B::Sample2
    end
  end

  describe '.load_map' do
    it 'loads classes and wrapped them into a hash' do
      entities = subject.load_map RSpec.spec_path.join('samples', 'components', '**', '*.rb')

      expect(entities).to be_a Hash
      expect(entities).to include(
        sample0: Sample0,
        a_sample1: A::Sample1,
        a_b_sample2: A::B::Sample2
      )
    end
  end
end
