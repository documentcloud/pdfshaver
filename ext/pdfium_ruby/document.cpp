#include "document.h"

/********************************************
* C++ Document definition
*********************************************/

Document::Document(const *char path) {
  // load the document via PDFium.
  this->document = FPDF_LoadDocument(path, NULL);
}

Document::~Document() {
  // make sure the document exists and was initialized before
  // trying to close it.
  if (document) { FPDF_CloseDocument(document); }
}

/********************************************
* Ruby class definition and initialization
*********************************************/

void Define_Document() {
  // Get the PDFium namespace and define the `Document` class inside it.
  VALUE rb_PDFium = rb_const_get(rb_cObject, rb_intern("PDFium"));
  VALUE rb_PDFium_Document = rb_const_get(rb_PDFium, rb_intern("Document"));
  
  rb_define_private_method(rb_PDFium_Document, "open_document_with_pdfium", 
                            CPP_RUBY_METHOD_FUNC(initialize_document_internals), -1);
};

// Entry point for PDFium::Document's ruby initializer into C++ land
VALUE initialize_document_internals(int arg_count, VALUE args, VALUE self) {
  VALUE path, options;
  // use Ruby's argument scanner to pull out a required
  // `path` argument and an optional `options` hash.
  rb_scan_args(arg_count, &args, "11", &path, &options);
  //rb_funcall(rb_cObject, rb_intern("puts"), 1, path);
  
  // attempt to open document.
  // path should at this point be validated & known to exist.
  document = new Document(path);
  
  return self;
}

static void document_allocate(VALUE klass) {
  
  return Data_Wrap_Struct(klass, NULL, document_deallocate, _document);
}
