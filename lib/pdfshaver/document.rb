module PDFShaver
  class Document
    attr_reader :length, :path
    
    def initialize path, options={}
      raise ArgumentError, "Can't find a file at '#{path}' to open" unless File.exists? path
      # otherwise attempt to acquire it.
      
      @path = path
      open_document_with_pdfium(path)
    end
    
    def == other
      File.realpath(self.path) == File.realpath(other.path)
    end
    
    def pages(page_list=:all)
      PageSet.new(self, page_list)
    end
  end
end
