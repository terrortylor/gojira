require 'rspec/core/rake_task'
require 'rubocop/rake_task'

namespace :test do
  desc 'Runs all rspec tests'
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = [].tap do |opts|
      opts.push('--color')
      opts.push('--format documentation')
    end.join(' ')
    t.verbose = false
  end

  desc 'Runs the rubocop linter'
  RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ['--display-cop-names']
  end

  desc 'Runs both the lint and unit tests'
  task :all do
    puts
    Rake::Task['test:rubocop'].invoke

    puts
    puts "Running rspec...\n"
    Rake::Task['test:rspec'].invoke
  end
end

namespace :gem do
  desc 'Build the gojira gem'
  task :build do
    system 'gem build gojira.gemspec'
  end

  desc 'Install the gem locally'
  task :install do
    system 'gem install gojira --no-doc'
  end
end

task default: 'test:all'
