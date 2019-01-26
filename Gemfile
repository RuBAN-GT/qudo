# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Gem dependencies
gemspec

# Local dependencies
gem 'rake', '~> 10.0'
gem 'rubocop', require: false

group :development, :test do
  gem 'faker', '~> 1.9'
  gem 'rspec', '~> 3.0'
  gem 'rspec_junit_formatter'
end

group :development do
  gem 'byebug', '~> 10.0'
  gem 'pry', '~> 0.12'
  gem 'pry-byebug', '~> 3.6'
  gem 'rerun', '~> 0.13'
end
