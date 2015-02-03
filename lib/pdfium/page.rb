module PDFium
  class Page
    def initialize document, number, options={}
      raise ArgumentError unless document.kind_of? PDFium::Document
      @document = document
      
      raise ArgumentError unless number.kind_of? Integer
      raise ArgumentError unless number > 0 and number < @document.length
    end
  end
  
  class PageSet
    attr_reader :document
    
    def initialize document, page_list=:all, options={}
      @document = document
    end
  end
end
