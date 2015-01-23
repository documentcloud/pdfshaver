module PDFium
end

%w[document page version].each do |file|
  require File.join(File.dirname(__FILE__), 'pdfium_ruby', file)
end
require File.join(File.dirname(__FILE__), 'pdfium_ruby')