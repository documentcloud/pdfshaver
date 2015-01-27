#ifndef __DOCUMENT_H__
#define __DOCUMENT_H__

#include "pdfium_ruby.h"
#include "fpdf_ext.h"

// C++ Class to wrap lifecycle of
// PDF Documents opened through PDFium.
class Document {
  public:

    // constructor
    Document(VALUE path);

    // wrapper for PDFium's pageCount
    int length();
    
    // flag to set instances as ready to be disposed of
    // pending ensuring all its pages have been first closed.
    void flagDocumentAsReadyForRelease();
    
    // a guard for the destructor.
    void destroyUnlessPagesAreOpen();

    // destructor
    ~Document();
    
  private:
    FPDF_DOCUMENT document;
    bool free_once_pages_are_closed;
    //std::unordered_set<Page*> open_pages;
};

static void destroy_document_when_safe(Document* document);

VALUE initialize_document_internals(int arg_count, VALUE* args, VALUE self);

#endif // __DOCUMENT_H__
