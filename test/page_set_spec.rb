require File.expand_path(File.join(File.dirname(__FILE__),'spec_helper'))

describe PDFium::PageSet do

  before do
    path = File.join(FIXTURES, 'uncharter.pdf')
    @document = PDFium::Document.new(path)
  end
  
  it "should be an enumerable collection of pages" do
    pages = PDFium::PageSet.new(@document)
    pages.must_be_instance_of PDFium::PageSet
    pages.must_respond_to(:each)
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
