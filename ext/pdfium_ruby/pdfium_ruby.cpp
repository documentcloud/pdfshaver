#include "pdfium_ruby.h"

#include "fpdfview.h"

extern "C"
void Init_pdfium_ruby (void) {
  // Initialize PDFium
  FPDF_InitLibrary();
  
  // Define `PDFium` module as a namespace for all of our other objects
  VALUE rb_PDFium = rb_define_module("PDFium");
  
  // Define `Document` and `Page` classes
  Define_Document();
  Define_Page();
  //Define_PageSet();
}
