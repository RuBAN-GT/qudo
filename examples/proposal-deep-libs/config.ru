# frozen_string_literal: true

require 'bundler/setup'

require_relative 'lib/roda_app_api/application'
require_relative 'lib/roda_app_api/router'

run RodaAppApi::Router.freeze.app
