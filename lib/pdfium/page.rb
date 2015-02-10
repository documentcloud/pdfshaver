module PDFium
  class Page
    attr_reader :document, :width, :height, :aspect, :number, :index
    
    def initialize document, number, options={}
      raise ArgumentError unless document.kind_of? PDFium::Document
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
  
  class PageSet
    include Enumerable

    attr_reader :document
    def initialize document, page_list=:all, options={}
      @document = document
    end
    
    def each(&block)
      enumerator.each(&block)
    end
    
    private
    def enumerator
      @enumerator ||= Enumerator.new do |yielder|
        Range.new(1, self.document.length).each do |page_number|
          yielder.yield Page.new(self.document, page_number)
        end
      end
    end
  end
end
