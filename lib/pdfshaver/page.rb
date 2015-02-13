module PDFShaver
  class Page
    attr_reader :document, :width, :height, :aspect, :number, :index
    
    def initialize document, number, options={}
      raise ArgumentError unless document.kind_of? PDFShaver::Document
      raise ArgumentError unless number.kind_of? Integer
      raise ArgumentError unless number > 0 and number <= document.length
      
      @number   = number
      @index    = number - 1
      @document = document
      initialize_page_internals document, @index
    end
    
    def == other
      raise ArgumentError, "unable to compare #{self.class} with #{other.class}" unless other.kind_of? self.class
      (self.document == other.document) and (self.index == other.index)
    end
    
    def <=> other
      raise ArgumentError, "unable to compare #{self.class} with #{other.class}" unless other.kind_of? self.class
      self.index <=> other.index
    end
  end
end
