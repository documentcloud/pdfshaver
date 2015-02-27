lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pdfshaver/version'

Gem::Specification.new do |s|
  s.name        = 'pdfshaver'
  s.version     = PDFShaver::VERSION
  s.licenses    = ['MIT']
  s.summary     = "Shave pages off of PDFs as images"
  s.description = <<-DESCRIPTION
  Shave pages off of PDFs as images.  PDFShaver makes iterating PDF pages easy 
  by wrapping Google Chrome's PDFium library in an enumerable interface.
  DESCRIPTION
  s.homepage    = 'https://www.documentcloud.org/opensource'
  s.authors     = ["Ted Han", "Nathan Stitt"]
  s.email       = 'opensource@documentcloud.org'
  s.extensions = 'ext/pdfium_ruby/extconf.rb'
  s.files       = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]
  
  s.add_development_dependency "bundler",       "~> 1.5"
  s.add_development_dependency 'rake',          "~>10.4"
  s.add_development_dependency 'rake-compiler', "~>0.9"
  s.add_development_dependency 'minitest',      "~>5.5"
  s.add_development_dependency 'fastimage',     "~>1.6"
end
