require_relative 'setup'
require 'benchmark'

here = File.dirname(__FILE__)
path = File.join(here, '..', 'test', 'fixtures', 'uncharter.pdf')
doc = PDFShaver::Document.new(path)
out_dir = File.join(here, 'output', 'speed')

count = 10
Benchmark.bm do |test|
  test.report("naive"){ count.times{ doc.pages.each{ |page| full_naive_render(page, out_dir) } } }
  test.report("smart"){ count.times{ doc.pages.each{ |page| full_smart_render(page, out_dir) } } }
end
