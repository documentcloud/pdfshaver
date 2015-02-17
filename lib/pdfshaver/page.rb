module PDFShaver
  class Page
    GM_MATCHER = /^((?<width>\d+)x((?<height>\d+))?|x?(?<height>\d+))(?<modifier>%|@|<|>)?$/
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
    
    def self.extract_dimensions_from_gm_geometry_string(arg)
      dimensions = {}
      arg.match(GM_MATCHER) do |match|
        
        puts match.inspect
        
        width    = match[:width].to_i unless match[:width].nil? 
        height   = match[:height].to_i unless match[:height].nil? 
        modifier = match[:modifier]
        
        case modifier
        when '%'
        when '@'
        when '<'
        when '>'
        end
        
        dimensions[:width]  = width || 0
        dimensions[:height] = height || 0
        return dimensions
      end
      
      raise ArgumentError, "unable to extract width & height from '#{arg}'"
    end
  end
end
