require 'byebug'
require 'fabrication'

require './app/application'
require_relative 'support/bitcoin'
require_relative 'support/helpers'

RSpec.configure do |config|
  config.include Support::Bitcoin
  config.include Support::Helpers

  config.around(:each) do |example|
    Sequel::Model.db.transaction(rollback: :always, auto_savepoint: true) do
      example.run
    end
  end

  config.expect_with(:rspec) do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect
  end

  config.mock_with(:rspec) do |mocks|
    mocks.verify_partial_doubles = true
  end

  if config.files_to_run.one?
    config.warnings = true
    config.profile_examples = false
    config.default_formatter = 'doc'
  else
    config.warnings = false
    config.profile_examples = 10
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.disable_monkey_patching!

  config.order = :random

  Kernel.srand(config.seed)
end
