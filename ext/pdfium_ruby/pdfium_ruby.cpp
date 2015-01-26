#include "pdfium_ruby.h"

extern "C"
void Init_pdfium_ruby (void) {
  // Define `PDFium` module as a namespace for all of our other objects
  VALUE rb_PDFium = rb_define_module("PDFium");
  
  // Define `Document` and `Page` classes
  Define_Document();
  //Define_Page();
  //Define_PageSet();
}
