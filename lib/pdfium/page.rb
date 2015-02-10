module PDFium
  class Page
    attr_reader :document, :width, :height, :aspect
    
    def initialize document, number, options={}
      raise ArgumentError unless document.kind_of? PDFium::Document
      raise ArgumentError unless number.kind_of? Integer
      raise ArgumentError unless number > 0 and number < document.length
      
      @number = number
      @index  = number - 1
      initialize_page_internals document, @index
    end
  end
  
  class PageSet
    attr_reader :document
    
    def initialize document, page_list=:all, options={}
      @document = document
    end
  end
end
