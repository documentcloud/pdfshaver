#include "pdfium_ruby.h"

void Init_pdfium_ruby (void) {
  VALUE rb_PDFium = rb_define_module("PDFium");
  
  // Define `Document` and `Page` classes
  Define_Document();
  Define_Page();
  Define_PageSet();
}
