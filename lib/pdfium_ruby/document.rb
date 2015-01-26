module PDFium
  class Document
    attr_reader :length
    
    def initialize path, options={}
      raise ArgumentError, "Can't find a file at '#{path}' to open" unless File.exists? path
      # otherwise attempt to acquire it.
      
      open_document_with_pdfium(path)
      @length = 0
    end
  end
end
