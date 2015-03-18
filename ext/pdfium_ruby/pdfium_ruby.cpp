#include "pdfium_ruby.h"

#include "fpdfview.h"

extern "C"
void Init_pdfium_ruby (void) {
  // Initialize PDFium
  FPDF_InitLibrary();
  
  // Define `PDFShaver` module as a namespace for all of our other objects
  rb_define_module("PDFShaver");
  
  // Define `Document` and `Page` classes
  Define_Document();
  Define_Page();
  //Define_PageSet();
}
