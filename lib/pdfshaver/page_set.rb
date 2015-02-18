module PDFShaver
  class PageSet
    include Enumerable

    attr_reader :document
    def initialize document, page_list=:all, options={}
      @document = document
      @page_list = extract_page_numbers(page_list)
    end
    
    def each(&block)
      enumerator.each(&block)
    end
    
    def [](page_index)
      Page.new(@document, @page_list.to_a[page_index])
    end
    
    def first
      Page.new(@document, @page_list.first)
    end
    
    def last
      Page.new(@document, @page_list.last)
    end
    
    def size
      @page_list.size
    end
    
    private
    def enumerator
      Enumerator.new do |yielder|
        @page_list.each do |page_number|
          yielder.yield Page.new(self.document, page_number)
        end
      end
    end
    
    def extract_page_numbers(inputs)
      case inputs
      when :all
        Range.new(1,self.document.length)
      when Numeric
        raise ArgumentError, "#{inputs} is not a valid page number" unless valid_page_number?(inputs)
        [inputs]
      when Range
        unless valid_page_range?(inputs)
          raise ArgumentError, "#{inputs} did not fall in a valid range of pages (#{1..self.document.length})"
        end
        inputs
      when Array
        numbers = []
        inputs.flatten.each do |input|
          case
          when valid_page_number?(input) then numbers.push input
          when valid_page_range?(input)  then numbers += input.to_a
          when valid_page_string?(input) then 
          else raise ArgumentError, "#{input} is not a valid page or list of pages (as part of #{inputs})"
          end
        end
        numbers.sort
      when String
        valid_page_string?(inputs)
      else 
        raise ArgumentError, "#{inputs.inspect} is not a valid list of pages"
      end
    end
    
    def valid_page_number?(number)
      number.kind_of?(Numeric) and number > 0 and number <= self.document.length
    end
    
    def valid_page_range?(range)
      range.kind_of?(Range) and range.first <= range.last and
      valid_page_number?(range.first) and valid_page_number?(range.last)
    end
    
    def valid_page_string?(input)
      raise ArgumentError, "todo: support strings as page specifiers"
    end
  end
end