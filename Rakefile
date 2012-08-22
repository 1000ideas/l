# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
require File.expand_path '../lib/l/version.rb', __FILE__
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "l"
  gem.version = L::VERSION
  gem.license = "MIT"
  gem.summary = %Q{Gem for lazy programmers}
  gem.description = %Q{Bunch of generators for lazy programmers}
  gem.email = "admin@1000i.pl"
  gem.authors = ["Bartek Bulat", "Krzystof Kosman"]
  gem.files = %w(LICENSE README INSTALL Rakefile) + Dir.glob("{app,vendor,config,lib,public}/**/*")

  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

#require 'rcov/rcovtask'
#Rcov::RcovTask.new do |test|
#  test.libs << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
#  test.rcov_opts << '--exclude "gems/*"'
#end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "l #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
