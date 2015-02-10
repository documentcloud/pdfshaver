require File.expand_path(File.join(File.dirname(__FILE__),'spec_helper'))

describe PDFium::Page do
  before do
    path = File.join(FIXTURES, 'uncharter.pdf')
    @document = PDFium::Document.new(path)
  end
  
  it "should be instantiated" do
    PDFium::Page.new(@document, 1).must_be_instance_of PDFium::Page
  end
  
  it "should throw an error if initialized without a document" do
    Proc.new{ PDFium::Page.new("lol", 1) }.must_raise ArgumentError
  end
  
  it "should throw an error if initialized with an invalid page number" do
    Proc.new{ PDFium::Page.new(@document) }.must_raise ArgumentError
    Proc.new{ PDFium::Page.new(@document, -12) }.must_raise ArgumentError
    Proc.new{ PDFium::Page.new(@document, 30000) }.must_raise ArgumentError
  end
  
  describe "instance methods" do
    before do
      @page = PDFium::Page.new(@document, 1)
      @output_path = File.join OUTPUT, 'image_render_test.gif'
    end

    it "should have the right width, height and aspect ratio" do
      @page.width.must_be_kind_of Integer
      @page.height.must_be_kind_of Integer
      @page.aspect.must_be_kind_of Float
    end
    
    it "should render an image and write it out to disk" do
      @page.render(@output_path).must_equal true
      File.exists?(@output_path).must_equal true
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
  
  describe "GC" do
    it "won't segfault if when a document is GCed" do
      doc = PDFium::Document.new(File.join(FIXTURES,'uncharter.pdf'))
      doc = nil
      GC.start
    end
    
    it "won't segfault if when an invalid document is GCed" do
      Proc.new{ PDFium::Document.new("suede shoes") }.must_raise ArgumentError
      GC.start
    end
    
    it "won't segfault if document falls out of scope before pages" do
      doc = PDFium::Document.new(File.join(FIXTURES,'uncharter.pdf'))
      p1 = PDFium::Page.new(doc, 1)
      doc = nil
      GC.start
      p1 = nil
      GC.start
    end
  end
end
