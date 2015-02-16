require File.expand_path(File.join(File.dirname(__FILE__),'spec_helper'))

describe PDFShaver::Document do
  
  it "should be instantiated" do
    path = File.join(FIXTURES, 'uncharter.pdf')
    PDFShaver::Document.new(path).must_be_instance_of PDFShaver::Document
  end
  
  it "should throw an error if path can't be found" do
    Proc.new{ PDFShaver::Document.new("suede shoes") }.must_raise ArgumentError
  end
  
  it "should throw an error if a document can't be opened" do
    Proc.new do
      path = File.join(FIXTURES, 'completely_encrypted.pdf')
      PDFShaver::Document.new(path)
    end.must_raise PDFShaver::EncryptionError
  end
  
  describe "instance methods" do
    before do
      @path = File.join(FIXTURES, 'uncharter.pdf')
      @document = PDFShaver::Document.new(@path)
    end
    
    it "should have a length" do
      @document.length.must_equal 55
    end
    
    it { @document.must_equal @document }
    it { @document.must_equal PDFShaver::Document.new(@path) }
    it { @document.wont_equal PDFShaver::Document.new(File.join(FIXTURES, 'letter-to-canadians-from-jack-layton.pdf')) }
  end
  
end