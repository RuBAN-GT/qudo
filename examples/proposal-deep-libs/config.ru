# frozen_string_literal: true

require 'bundler/setup'

require_relative 'lib/roda_app_api/application'

RodaAppApi::Application.boot
run RodaAppApi::Router.freeze.app
