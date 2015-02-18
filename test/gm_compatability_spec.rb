require File.expand_path(File.join(File.dirname(__FILE__),'spec_helper'))

describe "Resize arguments" do
  before do
    path = File.join(FIXTURES, 'uncharter.pdf')
    @document = PDFShaver::Document.new(path)
    @page = PDFShaver::Page.new(@document, 1)
  end

  describe "Syntax" do
    class TokenSet
      # Create a list of attributes which we can
      # refer back to later
      # and use the splat operator to define our attributes
      KEYS = [:width, :height, :modifier]
      attr_reader *KEYS

      # helper methods so we can pretend an instance is a hash
      def [](key); self.send(key); end
      def []=(key, val); self.instance_variable_set("@#{key}", val); end

      # use the KEYS and their order to initialize instance variables
      def initialize(*attributes)
        KEYS.each_with_index{ |key, index| self[key] = attributes[index] }
      end
    end
  
    it "should match valid graphicsmagick strings" do
      inputs = {
        "100"      => TokenSet.new(nil,   "100", nil),
        "101x102"  => TokenSet.new("101", "102", nil),
        "103x"     => TokenSet.new("103", nil,   nil),
        "x104"     => TokenSet.new(nil,   "104", nil),
        "105%"     => TokenSet.new(nil,   "105", "%"), 
        "106@"     => TokenSet.new(nil,   "106", "@"), 
        "107<"     => TokenSet.new(nil,   "107", "<"), 
        "108>"     => TokenSet.new(nil,   "108", ">"),
        "109x110%" => TokenSet.new("109", "110", "%"),
        "x111%"    => TokenSet.new(nil,   "111", "%"),
        "112x%"    => TokenSet.new("112", nil,   "%"),
      }
    
      inputs.each do |input, expected|
        input.must_match(PDFShaver::Page::GM_MATCHER)
        match = input.match(PDFShaver::Page::GM_MATCHER)
        TokenSet::KEYS.each{ |key| match[key].must_equal expected[key] }
      end
    end
  end

  describe "Semantic" do
    class Size
      attr_reader :width, :height, :aspect
      def initialize(width, height)
        @width = width
        @height = height
        @aspect = @width.to_f / height
      end

      def scale(factor)
        self.class.new((@width*factor).to_i, (@height*factor).to_i)
      end
    end
  
    it "should return an empty hash with nil or an empty string" do
      @page.extract_dimensions_from_gm_geometry_string(nil).must_equal({})
      @page.extract_dimensions_from_gm_geometry_string("").must_equal({})
    end
    
    it "should specify width and height" do
      w = @page.width.to_i
      h = @page.height.to_i
      base = Size.new(w,h)
      {
        "#{w}x#{h}"        => base,
        "#{(w*0.5).to_i}x" => base.scale(0.5),
        "x#{h*2}"          => base.scale(2),
        "100x100!"         => Size.new(100, 100),
        "100x100%"         => base,
        "200x200%"         => base.scale(2),
        "200x200@"         => Size.new(176, 227),
        "1000>"            => base,
        #"1000<"            => Size.new(773, 1000),
        "500>"             => Size.new(386, 500),
        "500x>"            => Size.new(500, 647)
      }.each do |input, expected|
        #puts "#{input} : #{expected.inspect}"
        output = @page.extract_dimensions_from_gm_geometry_string(input)
        #puts "#{output.inspect} vs #{expected.inspect}"
        dimensions = Size.new(output[:width], output[:height])
        dimensions.aspect.must_be_within_delta expected.aspect, 0.005
        dimensions.width.must_be_within_delta expected.width, 1
        dimensions.height.must_be_within_delta expected.height, 1
      end
    end
  end
end
