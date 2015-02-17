module PDFShaver
  class Page
    GM_MATCHER = /^\s*((?<width>\d+)x((?<height>\d+))?|x?(?<height>\d+))(?<modifier>[@%!<>^]+)?\s*$/
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
    
    def extract_dimensions_from_gm_geometry_string(arg)
      dimensions = {}
      arg.match(GM_MATCHER) do |match|
        
        # grab parsed tokens
        requested_width  = match[:width].to_f unless match[:width].nil? 
        requested_height = match[:height].to_f unless match[:height].nil? 
        modifier         = match[:modifier] || ""
        
        ## Algorithm ported from GraphicsMagick's GetMagickGeometry function.
        #
        # the '@' option precludes all other options.
        if modifier.include? '@'
          # calculate the current page area
          # and the specified target area for comparison
          current_area = self.width * self.height
          target_area  = (requested_width || 1) * (requested_height || 1)
          
          resize = if modifier.include? '>'
            current_area > target_area
          elsif modifier.include? '<'
            current_area < target_area
          else
            true
          end
          
          if resize
            scale = 1.0 / Math.sqrt(current_area/target_area)
            dimensions[:width]  = (self.width*scale+0.25).floor
            dimensions[:height] = (self.height*scale+0.25).floor
          end
        else # Handle all of the non area modes.
          width = requested_width
          height = requested_height
          
          # when supplied with only a width or a height
          # infer the other using the page's aspect ratio.
          if width and not height
            height = (width/self.aspect+0.5).floor
          elsif height and not width
            width  = (self.width.to_f/self.height*height+0.5).floor
          end
          
          # If proportional mode is requested
          # 
          if modifier.include? '%'
            x_scale = width
            y_scale = height
            x_scale = y_scale if requested_width.nil? or requested_height.nil?
            width   = ((self.width * x_scale / 100.0) +0.5).floor
            height  = ((self.height * y_scale / 100.0) +0.5).floor
            # this is to match how GraphicsMagick works.
            requested_width = width
            requested_height = height
          end
          
          if modifier.include? '!' and ((width != requested_width) || (height != requested_height))
            if (requested_width == 0) || (requested_height == 0)
              scale = 1.0
            else
              width_ratio  = width / self.width
              height_ratio = height / self.height
              scale = width_ratio
            end
            
            width  = (scale*self.width+0.5).floor
            height = (scale*self.height+0.5).floor
          end
          
          if modifier.include? '>'
            width  = self.width  if self.width  < width
            height = self.height if self.height < height
          end
          
          if modifier.include? '<'
            width  = self.width  if self.width  > width
            height = self.height if self.height > height
          end
          
          dimensions[:width]  = width.floor
          dimensions[:height] = height.floor
        end
        dimensions[:width]  ||= self.width.floor
        dimensions[:height] ||= self.height.floor
        return dimensions
      end
      
      raise ArgumentError, "unable to extract width & height from '#{arg}'"
    end
  end
end
