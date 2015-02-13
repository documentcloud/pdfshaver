module PDFium
end

%w[
  document
  page
  page_set
  version
].each do |file|
  require_relative File.join('pdfshaver', file)
end
require_relative 'pdfium_ruby'
