require "minitest/autorun"
require 'fastimage'
require 'fileutils'

HERE = File.expand_path File.dirname(__FILE__)
FIXTURES = File.join(HERE, 'fixtures')
OUTPUT = File.join(HERE, 'output')
FileUtils.mkdir_p OUTPUT

MiniTest::Unit.after_tests { FileUtils.rm_r(OUTPUT) if File.exists?(OUTPUT) and not ENV["DEBUG"] }

require File.join(HERE, '..', 'lib', 'pdfshaver')

