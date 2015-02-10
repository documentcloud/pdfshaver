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