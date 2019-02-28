# frozen_string_literal: true

require 'bundler/setup'
require_relative 'lib/api/application'

run Api::Application.run
