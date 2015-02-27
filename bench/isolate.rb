require_relative '../lib/pdfshaver'
require 'fileutils'
require 'pp'

def extract(doc_path, prefix=rand(10**10))
  out_dir = File.join(".", "output", prefix.to_s)
  FileUtils.mkdir_p(out_dir)
  log = File.open(File.join(out_dir, "log.txt"), 'w')
  log.sync = true
  doc = PDFShaver::Document.new(doc_path)
  doc.pages.each do |page|
    log.puts("#{Time.now}: rendering page #{page.number}")
    # shamelessly stolen from http://samsaffron.com/archive/2014/04/08/ruby-2-1-garbage-collection-ready-for-production
    log.puts "RSS: #{`ps -eo rss,pid | grep #{Process.pid} | grep -v grep | awk '{ print $1;  }'`}"
    #GC.start
    #log.puts(GC.stat)
    easy_render(page, out_dir)
  end
  log.puts ("#{Time.now}: Done!")
end

# A method to test basic rendering
def easy_render(page, dir)
  out_path = File.join(dir,"#{page.number}.gif")
  page.render(out_path)
  page.send(:unload_data)
end

# A method for testing rendering a variety of pages
# but as it turns out rendering isn't the problem so
# this method isn't any heavier in memory usage than
# the easy render!
def full_render(page, dir)
  sizes = %w[1000x 700x 180x 60x75!]
  sizes.each do |size_string|
    dimensions = page.extract_dimensions_from_gm_geometry_string(size_string)
    out_path = File.join(dir,"#{page.number}_#{size_string}.gif")
    #puts out_path
    page.render(out_path, dimensions)
  end
end

some_number_of = ARGV.pop.to_i
some_number_of = 5 if some_number_of <= 0
puts "firing up #{some_number_of} forks"
some_number_of.times do |n|
  fork do 
    here = File.dirname(__FILE__)
    path = File.join(here, '..', 'test', 'fixtures', 'uncharter.pdf')
    extract(path, n)
  end
end

=begin
Questions:
* What can/should trigger Ruby's GC?
* What's the stack size look like?
* Is Ruby accurately reporting the amount of memory allocated? (how do we compare?)
=end