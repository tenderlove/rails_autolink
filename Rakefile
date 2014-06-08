# Setup some testing
require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.pattern = 'test/test_*.rb'
end

task :default => :test