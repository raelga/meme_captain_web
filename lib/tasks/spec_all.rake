# frozen_string_literal: true
desc 'Run all specs'.freeze
task 'spec:all'.freeze => [
  'spec:javascript'.freeze,
  :coffeelint,
  :rails_best_practices,
  :rubocop,
  :spec
]
