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
    it { @document.pages.must_be_instance_of PDFium::PageSet }
    
    it "should have accessors to specific pages" do
      @document.pages[0].must_equal PDFium::Page.new(@document, 1)
      @document.pages[@document.length-1].must_equal PDFium::Page.new(@document, @document.length)
    end
  end
end
