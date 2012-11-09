require 'rubygems'
require 'rake'
require './lib/dascitizen.rb'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.version = DasCitizen::VERSION
  gem.name = "dascitizen"
  gem.homepage = "http://github.com/rubiojr/dascitizen"
  gem.license = "MIT"
  gem.summary = %Q{The Great VPN}
  gem.description = %Q{The Great VPN}
  gem.email = "rubiojr@frameos.org"
  gem.authors = ["Sergio Rubio"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #gem.add_runtime_dependency 'alchemist'
  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :build
