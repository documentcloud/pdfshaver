require File.expand_path(File.join(File.dirname(__FILE__),'spec_helper'))

describe GC do
  it "won't segfault if when a document is GCed" do
    doc = PDFShaver::Document.new(File.join(FIXTURES,'uncharter.pdf'))
    doc = nil
    GC.start
  end
  
  it "won't segfault if when an invalid document is GCed" do
    Proc.new{ PDFShaver::Document.new("suede shoes") }.must_raise ArgumentError
    GC.start
  end
  
  it "won't segfault if document falls out of scope before pages" do
    doc = PDFShaver::Document.new(File.join(FIXTURES,'uncharter.pdf'))
    p1 = PDFShaver::Page.new(doc, 1)
    doc = nil
    GC.start
    p1 = nil
    GC.start
  end
end