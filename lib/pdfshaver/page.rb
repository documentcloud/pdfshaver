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
  
  class PageSet
    include Enumerable

    attr_reader :document
    def initialize document, page_list=:all, options={}
      @page_list = page_list
      @document = document
    end
    
    def each(&block)
      enumerator(@page_list).each(&block)
    end
    
    def [](page_index)
      Page.new(@document, page_index+1)
    end
    
    private
    def enumerator(possible_page_numbers="")
      page_numbers = extract_page_numbers possible_page_numbers
      Enumerator.new do |yielder|
        page_numbers.each do |page_number|
          yielder.yield Page.new(self.document, page_number)
        end
      end
    end
    
    def extract_page_numbers(inputs="")
      return inputs if inputs.kind_of? Range
      numbers = Range.new(1,self.document.length)
    end
  end
end
