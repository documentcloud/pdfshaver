lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdfshaver/version'

Gem::Specification.new do |s|
  s.name        = 'pdfshaver'
  s.version     = PDFShaver::VERSION
  s.licenses    = ['MIT']
  s.summary     = "Slice pages off of PDFs as images"
  s.authors     = ["Ted Han", "Nathan Stitt"]
  s.email       = 'opensource@documentcloud.org'
  s.files       = Dir.glob %w[
    lib/**
    ext/**
    test/**
    Gemfile
    pdfshaver.gemspec
    Rakefile
    Readme.md
  ]
  
  s.add_development_dependency "bundler", "~> 1.5"
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rake-compiler'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'fastimage'
end
