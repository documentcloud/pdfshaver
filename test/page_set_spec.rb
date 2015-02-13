require File.expand_path(File.join(File.dirname(__FILE__),'spec_helper'))

describe PDFShaver::PageSet do

  before do
    path = File.join(FIXTURES, 'uncharter.pdf')
    @document = PDFShaver::Document.new(path)
  end
  
  it "should be an enumerable collection of pages" do
    pages = PDFShaver::PageSet.new(@document)
    pages.must_be_instance_of PDFShaver::PageSet
    pages.must_respond_to(:each)
  end
  
  it "should iterate all pages by default" do
    counter = 0
    PDFShaver::PageSet.new(@document).each{ |page| counter += 1 }
    counter.must_equal @document.length
  end
  
  it "should iterate through a specified list of pages" do
    counter = 0
    PDFShaver::PageSet.new(@document, Range.new(1, @document.length/2)).each{ |page| counter += 1 }
    counter.must_equal @document.length/2
  end
  
  describe "Document PageSet Interface" do
    it { @document.pages.must_be_instance_of PDFShaver::PageSet }
    
    it "should have accessors to specific pages" do
      @document.pages[0].must_equal PDFShaver::Page.new(@document, 1)
      @document.pages[@document.length-1].must_equal PDFShaver::Page.new(@document, @document.length)
    end
  end
end
