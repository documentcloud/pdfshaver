module PDFShaver
  class PageSet
    include Enumerable

    attr_reader :document
    def initialize document, page_list=:all, options={}
      @document = document
      @page_list = extract_page_numbers(page_list)
    end
    
    def each(&block)
      enumerator(@page_list).each(&block)
    end
    
    def [](page_index)
      Page.new(@document, page_index+1)
    end
    
    def first
      Page.new(@document, 1)
    end
    
    def last
      Page.new(@document, @document.length)
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