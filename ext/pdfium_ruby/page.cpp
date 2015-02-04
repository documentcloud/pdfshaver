#include "page.h"

/********************************************
* C++ Page definition
*********************************************/

Page::Page() {}

bool Page::load(Document* document, int page_number) {
  this->document = document;
  this->page_number = page_number;
  
  this->page = FPDF_LoadPage(document->fpdf_document(), page_number);
  document->notifyPageOpened(this);
  return true;
}

float
Page::aspect() {
  return (float)(width()) / (float)(height());
}

double
Page::width(){
    return FPDF_GetPageWidth(this->page);
}


double
Page::height(){
    return FPDF_GetPageHeight(this->page);
}

Page::~Page() { this->document->notifyPageClosed(this); }

/********************************************
* Ruby class definition and initialization
*********************************************/

void Define_Page() {
  // Get the PDFium namespace and get the `Page` class inside it.
  VALUE rb_PDFium = rb_const_get(rb_cObject, rb_intern("PDFium"));
  VALUE rb_PDFium_Page = rb_const_get(rb_PDFium, rb_intern("Page"));
  
  rb_define_alloc_func(rb_PDFium_Page, *page_allocate);
  
  rb_define_private_method(rb_PDFium_Page, "initialize_page_internals", 
                            CPP_RUBY_METHOD_FUNC(initialize_page_internals), -1); 
}

VALUE page_allocate(VALUE rb_PDFium_Page) {
  Page* page = new Page();
  return Data_Wrap_Struct(rb_PDFium_Page, NULL, destroy_page, page);
}

VALUE initialize_page_internals(int arg_count, VALUE* args, VALUE self) {
  // use Ruby's argument scanner to pull out a required
  // `path` argument and an optional `options` hash.
  VALUE rb_document, page_number, options;
  int number_of_args = rb_scan_args(arg_count, args, "12", &rb_document, &page_number, &options);
  
  // Get the PDFium namespace and get the `Page` class inside it.
  VALUE rb_PDFium = rb_const_get(rb_cObject, rb_intern("PDFium"));
  VALUE rb_PDFium_Page = rb_const_get(rb_PDFium, rb_intern("Page"));
  
  Document* document;
  Data_Get_Struct(rb_document, Document, document);
  
  Page* page;
  Data_Get_Struct(self, Page, page);
  
  page->load(document, FIX2INT(page_number));
  
  rb_ivar_set(self, rb_intern("@width"),  INT2FIX(page->width()));
  rb_ivar_set(self, rb_intern("@height"), INT2FIX(page->height()));
  rb_ivar_set(self, rb_intern("@aspect"), rb_float_new(page->aspect()));
  
  return self;
}

static void destroy_page(Page* page) { delete page; }