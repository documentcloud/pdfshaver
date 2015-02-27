require_relative 'setup'

here = File.dirname(__FILE__)
path = File.join(here, '..', 'test', 'fixtures', 'uncharter.pdf')
doc = PDFShaver::Document.new(doc_path)

doc.pages.each do |page|
  full_smart_render(page, out_dir)
end

doc.pages.each do |page|
  full_naive_render(page, out_dir)
end