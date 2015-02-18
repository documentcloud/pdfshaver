require File.expand_path(File.join(File.dirname(__FILE__),'spec_helper'))

describe PDFShaver::PageSet do

  before do
    path              = File.join(FIXTURES, 'uncharter.pdf')
    @document         = PDFShaver::Document.new(path)
    @first_half_range = Range.new(1, @document.length/2)
    @last_half_range  = Range.new(@document.length/2, @document.length)
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
    PDFShaver::PageSet.new(@document, @first_half_range).each{ |page| counter += 1 }
    counter.must_equal @document.length/2
  end
  
  it "should provide a number of ways to express page lists" do
    { 1           => 1,
      [1,2,3,5,8] => 5,
      5..10       => 6,
      [1, 5..10]  => 7
    }.each do |list, count| 
      #puts list.inspect
      PDFShaver::PageSet.new(@document, list).size.must_equal count
    end
  end
  
  it "should reject any page value that's out of bounds" do
    [5000, -1, 5..-5, 10..8].each do|input| 
      Proc.new{ PDFShaver::PageSet.new(@document, input) }.must_raise ArgumentError
    end
  end
  
  it "should provide an accessor, #first and #last to specify the set" do
    pages = PDFShaver::PageSet.new(@document, @last_half_range)
    pages.first.must_equal PDFShaver::Page.new(@document, @last_half_range.first)
    pages.last.must_equal  PDFShaver::Page.new(@document, @last_half_range.last)
    pages[1].must_equal    PDFShaver::Page.new(@document, @last_half_range.first+1)
  end
  
  describe "Document PageSet Interface" do
    it { @document.pages.must_be_instance_of PDFShaver::PageSet }
    
    it "should have accessors to specific pages" do
      @document.pages[0].must_equal PDFShaver::Page.new(@document, 1)
      @document.pages[@document.length-1].must_equal PDFShaver::Page.new(@document, @document.length)
    end
  end
end
