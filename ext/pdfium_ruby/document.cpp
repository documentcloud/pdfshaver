#include "document.h"

/********************************************
* C++ Document definition
*********************************************/

Document::Document(VALUE path) {
  // load the document via PDFium.
  // returns false if loading document fails.
  this->document = FPDF_LoadDocument(StringValuePtr(path), NULL);
  // indicate that Ruby is still using this document.
  this->free_once_pages_are_closed = false;
}

Document::~Document() {
  // make sure the document exists and was initialized before
  // trying to close it.
  if (document) { FPDF_CloseDocument(document); }
}

int Document::length() { return FPDF_GetPageCount(document); }

void Document::flagDocumentAsReadyForRelease() { this->free_once_pages_are_closed = true; }

void Document::destroyUnlessPagesAreOpen() {
  // once the document is no longer being used, and none of its child pages are open
  // it's safe to destroy.
  if (free_once_pages_are_closed /*&& open_pages.empty()*/) { delete this; }
}

/********************************************
* Ruby class definition and initialization
*********************************************/

void Define_Document() {
  // Get the PDFium namespace and get the `Document` class inside it.
  VALUE rb_PDFium = rb_const_get(rb_cObject, rb_intern("PDFium"));
  VALUE rb_PDFium_Document = rb_const_get(rb_PDFium, rb_intern("Document"));
  
  rb_define_private_method(rb_PDFium_Document, "open_document_with_pdfium", 
                            CPP_RUBY_METHOD_FUNC(initialize_document_internals), -1);
};

// Entry point for PDFium::Document's ruby initializer into C++ land
VALUE initialize_document_internals(int arg_count, VALUE* args, VALUE self) {

  // use Ruby's argument scanner to pull out a required
  // `path` argument and an optional `options` hash.
  VALUE path, options;
  int number_of_args = rb_scan_args(arg_count, args, "11", &path, &options);
  
  // attempt to open document.
  // path should at this point be validated & known to exist.
  Document* document = new Document(path);

  // Get the PDFium namespace and get the `Document` class inside it.
  VALUE rb_PDFium = rb_const_get(rb_cObject, rb_intern("PDFium"));
  VALUE rb_PDFium_Document = rb_const_get(rb_PDFium, rb_intern("Document"));
  Data_Wrap_Struct(rb_PDFium_Document, NULL, destroy_document_when_safe, document);
  
  // get the document length and store it as an instance variable on the class.
  rb_ivar_set(self, rb_intern("@length"), INT2FIX(document->length()));
  return self;
}

static void destroy_document_when_safe(Document* document) {
  document->flagDocumentAsReadyForRelease();
  document->destroyUnlessPagesAreOpen();
}
