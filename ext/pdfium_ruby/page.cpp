#include "page.h"

/********************************************
* C++ Page definition
*********************************************/

Page::Page(Document* document, int page_number) {
  
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


/********************************************
* Ruby class definition and initialization
*********************************************/

void Define_Page() {
  // Get the PDFium namespace and get the `Page` class inside it.
  VALUE rb_PDFium = rb_const_get(rb_cObject, rb_intern("PDFium"));
  VALUE rb_PDFium_Document = rb_const_get(rb_PDFium, rb_intern("Page"));
  
  rb_define_private_method(rb_PDFium_Document, "open_page_with_pdfium", 
                            CPP_RUBY_METHOD_FUNC(initialize_page_internals), -1); 
}

VALUE initialize_page_internals(int arg_count, VALUE* args, VALUE self) {
  
}
