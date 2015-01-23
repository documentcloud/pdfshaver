require "bundler/gem_tasks"
require 'rake/extensiontask'

Rake::ExtensionTask.new('pdfium_ruby')

task :test => :compile do
  Dir.glob(File.join File.dirname(__FILE__), "test", "**", "*_spec.rb").each{ |test| require test }
end

task(default: :test)