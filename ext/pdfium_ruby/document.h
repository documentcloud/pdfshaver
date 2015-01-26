#ifndef __DOCUMENT_H__
#define __DOCUMENT_H__

#include "pdfium_ruby.h"
#include "fpdf_ext.h"

// C++ Class to wrap lifecycle of
// PDF Documents opened through PDFium.
class Document {
  public:

    // constructor
    Document();

    // destructor
    ~Document();

  private:
    FPDF_DOCUMENT _document;
};


#endif // __DOCUMENT_H__
