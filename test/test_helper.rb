# frozen_string_literal: true

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'

  gem 'minitest-reporters'
end

Minitest::Reporters.use!
