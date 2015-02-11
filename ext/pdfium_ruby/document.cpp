#include "document.h"

/********************************************
* C++ Document definition
*********************************************/

Document::Document() {
  // Initialize state variables
  // to mark whether document has been used
  // and whether document is freeable.
  this->opened            = false;
  this->ready_to_be_freed = true;
}

Document::~Document() {
  // make sure the document exists and was initialized before
  // trying to close it.
  if (this->opened) { FPDF_CloseDocument(this->fpdf_document); }
}

bool Document::load(VALUE path) {
  // load the document via PDFium.
  // returns false if loading document fails.
  this->fpdf_document = FPDF_LoadDocument(StringValuePtr(path), NULL);
  // indicate that Ruby is still using this document.
  this->opened = !!(this->fpdf_document);
  this->ready_to_be_freed = false;
  return this->opened;
}

int Document::length() { return FPDF_GetPageCount(this->fpdf_document); }

void Document::flagDocumentAsReadyForRelease() { this->ready_to_be_freed = true; }


void Document::notifyPageOpened(Page* page) {
  //ruby_puts_cstring("Adding page to open pages");
  this->open_pages.insert(page);
}
void Document::notifyPageClosed(Page* page) {
  //ruby_puts_cstring("Removing page from open pages");
  this->open_pages.erase(page);
  this->destroyUnlessPagesAreOpen();
}
void Document::destroyUnlessPagesAreOpen() {
  // once the document is no longer being used, and none of its child pages are open
  // it's safe to destroy.
  if (!(this->opened) || (this->opened && this->ready_to_be_freed && this->open_pages.empty())) { 
    //ruby_puts_cstring("Deleting Document");
    delete this;
  }
}

/********************************************
* Ruby class definition and initialization
*********************************************/

void Define_Document() {
  // Get the PDFShaver namespace and get the `Document` class inside it.
  VALUE rb_PDFShaver = rb_const_get(rb_cObject, rb_intern("PDFShaver"));
  VALUE rb_PDFShaver_Document = rb_const_get(rb_PDFShaver, rb_intern("Document"));
  
  rb_define_alloc_func(rb_PDFShaver_Document, *document_allocate);
  
  rb_define_private_method(rb_PDFShaver_Document, "open_document_with_pdfium", 
                            CPP_RUBY_METHOD_FUNC(initialize_document_internals), -1);
};

VALUE document_allocate(VALUE rb_PDFShaver_Document) {
  Document* document = new Document();
  return Data_Wrap_Struct(rb_PDFShaver_Document, NULL, destroy_document_when_safe, document);
}

// Entry point for PDFShaver::Document's ruby initializer into C++ land
VALUE initialize_document_internals(int arg_count, VALUE* args, VALUE self) {
  // Get the PDFShaver namespace and get the `Document` class inside it.
  VALUE rb_PDFShaver = rb_const_get(rb_cObject, rb_intern("PDFShaver"));
  VALUE rb_PDFShaver_Document = rb_const_get(rb_PDFShaver, rb_intern("Document"));
  
  // use Ruby's argument scanner to pull out a required
  // `path` argument and an optional `options` hash.
  VALUE path, options;
  int number_of_args = rb_scan_args(arg_count, args, "11", &path, &options);

  // attempt to open document.
  // path should at this point be validated & known to exist.
  Document* document;
  Data_Get_Struct(self, Document, document);
  document->load(path);
  //if (!document->isValid()) { rb_raise(rb_eArgError, "Failed to load: %s", StringValuePtr(path)); }
  
  // get the document length and store it as an instance variable on the class.
  rb_ivar_set(self, rb_intern("@length"), INT2FIX(document->length()));
  return self;
}

static void destroy_document_when_safe(Document* document) {
  document->flagDocumentAsReadyForRelease();
  document->destroyUnlessPagesAreOpen();
}
