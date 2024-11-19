# frozen_string_literal: true

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'minitest-reporters'
  gem 'simplecov'
end

Minitest::Reporters.use!

SimpleCov.start do
  enable_coverage :branch
  add_filter '/test/'
end
