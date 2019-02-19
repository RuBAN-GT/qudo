# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qudo/version'

Gem::Specification.new do |spec|
  spec.name    = 'qudo'
  spec.version = Qudo::VERSION
  spec.authors = ['Dmitry Ruban']
  spec.email   = ['dkruban@gmail.com']

  spec.summary     = 'Write a short summary, because RubyGems requires one.'
  spec.description = 'Write a longer description or delete this line.'
  spec.homepage    = 'https://github.com/RuBAN-GT'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'

  # Main dependencies
  spec.add_runtime_dependency 'dry-inflector', '~> 0.1.2'
  spec.add_runtime_dependency 'hashie', '~> 3.6'
  spec.add_runtime_dependency 'hooks', '~> 0.4'

  spec.add_development_dependency 'bundler', '>= 1.17'
end
