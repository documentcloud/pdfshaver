require File.expand_path(File.join(File.dirname(__FILE__),'spec_helper'))

describe PDFium::Document do
  
  it "should be instantiated" do
    path = File.join(FIXTURES, 'uncharter.pdf')
    PDFium::Document.new(path).must_be_instance_of PDFium::Document
  end
  
  it "should throw an error if path can't be found" do
    Proc.new{ PDFium::Document.new("suede shoes") }.must_raise ArgumentError
  end
  
  describe "instance methods" do
    before do
      path = File.join(FIXTURES, 'uncharter.pdf')
      @document = PDFium::Document.new(path)
    end
    
    it "should have a length" do
      @document.length.must_equal 55
    end
  end
  
end

describe PDFium::PageSet do

  before do
    path = File.join(FIXTURES, 'uncharter.pdf')
    @document = PDFium::Document.new(path)
  end
  
  it "should be an enumerable collection of pages" do
    pages = PDFium::PageSet.new(@document)
    pages.must_be_instance_of PDFium::PageSet
  end

  describe "Document PageSet Interface" do
    it "should have an iterator" do
      skip
      pages = @document.pages(1..(@document.length/2)) # should be an enumerator of pages.
      pages.length.must_equal @document.length/2

      @document.pages.each do |page|
        options = {}
        image = page.rasterize(:gif, options) # => PDFium::GIF
        image.save(path)
      end
    end
  end
  
end

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
    before { @page = PDFium::Page.new(@document, 1) }
    it "should have the right width, height and aspect ratio" do
      @page.width.must_be_kind_of Integer
      @page.height.must_be_kind_of Integer
      @page.aspect.must_be_kind_of Float
    end
  end
  
  describe "GC" do
    it "wont blow up if doc falls out of scope before pages" do
      doc = PDFium::Document.new(File.join(FIXTURES,'uncharter.pdf'))
      p1 = PDFium::Page.new(@document, 1)
      doc = nil
      GC.start
      p1 = nil
      GC.start
    end
  end
end
