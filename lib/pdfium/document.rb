module PDFium
  class Document
    attr_reader :length
    
    def initialize path, options={}
      raise ArgumentError, "Can't find a file at '#{path}' to open" unless File.exists? path
      # otherwise attempt to acquire it.
      
      open_document_with_pdfium(path)
    end
    
    def pages(page_list=:all)
      PageSet.new(self, page_list)
    end
  end
end
