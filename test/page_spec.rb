require File.expand_path(File.join(File.dirname(__FILE__),'spec_helper'))

describe PDFShaver::Page do
  before do
    path = File.join(FIXTURES, 'uncharter.pdf')
    @document = PDFShaver::Document.new(path)
  end
  
  it "should be instantiated" do
    PDFShaver::Page.new(@document, 1).must_be_instance_of PDFShaver::Page
  end
  
  it "should throw an error if initialized without a document" do
    Proc.new{ PDFShaver::Page.new("lol", 1) }.must_raise ArgumentError
  end
  
  it "should only instantiate pages with a valid page number" do
    Proc.new{ PDFShaver::Page.new(@document) }.must_raise ArgumentError
    Proc.new{ PDFShaver::Page.new(@document, -12) }.must_raise ArgumentError
    Proc.new{ PDFShaver::Page.new(@document, 0) }.must_raise ArgumentError
    Proc.new{ PDFShaver::Page.new(@document, @document.length+1) }.must_raise ArgumentError

    PDFShaver::Page.new(@document, 1).must_be_instance_of PDFShaver::Page
    PDFShaver::Page.new(@document, @document.length).must_be_instance_of PDFShaver::Page
  end
  
  describe "instance methods" do
    before do
      @page = PDFShaver::Page.new(@document, 1)
      @output_path = File.join OUTPUT, 'image_render_test.gif'
    end
    
    it "should have the right width, height and aspect ratio" do
      @page.width.must_be_kind_of Integer
      @page.height.must_be_kind_of Integer
      @page.aspect.must_be_kind_of Float
      @page.document.must_be_same_as @document
    end
    
    it "should have a comparator and know which order pages go in" do
      p1 = PDFShaver::Page.new(@document, 1)
      p2 = PDFShaver::Page.new(@document, 2)
      p3 = PDFShaver::Page.new(@document, 3)
      
      (p2 <=> p1).must_equal 1
      (p2 <=> p2).must_equal 0
      (p2 <=> p3).must_equal -1
      
      Proc.new{ p2 <=> :lol }.must_raise ArgumentError
    end
    
    it { @page.must_equal @page }
    it { @page.must_equal PDFShaver::Page.new(@document,@page.number) }
    
    it "shouldn't be equal to a page with the same number from another document" do 
      other_document = PDFShaver::Document.new(File.join(FIXTURES, 'letter-to-canadians-from-jack-layton.pdf'))
      (@page.document).wont_equal other_document
      @page.wont_equal PDFShaver::Page.new(other_document, @page.number)
    end
    
    it "should render an image and write it out to disk" do
      @page.render(@output_path).must_equal true
      File.exists?(@output_path).must_equal true
    end
    
    it "should throw an error when saving to an unrecognized file type" do
      fail_path = File.join(OUTPUT, "this_will_never_be.a_valid_filetype")
      Proc.new{ @page.render(fail_path) }.must_raise ArgumentError
      File.exists?(fail_path).must_equal false
    end
    
    it "should raise an error if output path is missing" do
      Proc.new{ @page.render }.must_raise ArgumentError
    end
    
    it "should use default page size if dimensions aren't specified" do
      @page.render @output_path
      FastImage.size(@output_path).zip([@page.width, @page.height]).each do |actual, expected|
        actual.must_equal expected
      end
    end
    
    it "should scale image when height is specified" do
      target_height = 1000
      @page.render @output_path, height:target_height, width:nil
      width, height = FastImage.size @output_path
      height.must_equal target_height
    end

    it "should scale image when width is specified" do
      target_width = 1000
      @page.render @output_path, height:nil, width:target_width
      width, height = FastImage.size @output_path
      width.must_equal target_width
    end
    
    it "should scale image when height and width are specified" do
      target_height = target_width = 1000
      @page.render @output_path, height:target_height, width:target_width
      width, height = FastImage.size @output_path
      width.must_equal target_width
      height.must_equal target_height
    end
    
    it "should preserve aspect ratio when scaling" do
      @page.render @output_path, height:1000, width:nil
      width, height = FastImage.size @output_path
      (width.to_f / height).must_be_within_delta @page.aspect, 0.001
    end
  end
  
  describe "lazy loading" do
    before do
      @page = PDFShaver::Page.new(@document, 1)
      @output_path = File.join OUTPUT, 'image_render_test.gif'
    end
    
    it "should be safe to reuse pages" do
      @page.instance_variable_get("@extension_data_is_loaded").must_equal false
      @page.render(@output_path)
      @page.instance_variable_get("@extension_data_is_loaded").must_equal false
      @page.render(@output_path)
      @page.instance_variable_get("@extension_data_is_loaded").must_equal false
    end
    
    it "should not load data until requested" do
      @page.instance_variable_get("@extension_data_is_loaded").must_equal false
      @page.instance_variable_get("@height").must_be_nil
      @page.instance_variable_get("@width" ).must_be_nil
      @page.instance_variable_get("@aspect").must_be_nil
      @page.instance_variable_get("@length").must_be_nil
      
      @page.instance_variable_get("@extension_data_is_loaded").must_equal false
      @page.send(:load_dimensions)
      @page.instance_variable_get("@extension_data_is_loaded").must_equal false
      wont_be_nil @page.height
      wont_be_nil @page.width
      wont_be_nil @page.aspect
      #wont_be_nil @page.length
      @page.instance_variable_get("@extension_data_is_loaded").must_equal false
    end
    
    it "should provide a scope where data is kept loaded" do
      @page.instance_variable_get("@extension_data_is_loaded").must_equal false
      @page.with_data_loaded do
        @page.instance_variable_get("@extension_data_is_loaded").must_equal true
      end
      @page.instance_variable_get("@extension_data_is_loaded").must_equal false
    end
    
    it "shouldn't blow up if nested twice" do
      @page.with_data_loaded do |p|
        p.with_data_loaded do |lol|
          lol
        end
      end
    end
  end
end
