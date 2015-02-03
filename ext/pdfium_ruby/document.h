#ifndef __DOCUMENT_H__
#define __DOCUMENT_H__

#include "pdfium_ruby.h"
#include "fpdf_ext.h"
#include "page.h"

// C++ Class to wrap lifecycle of
// PDF Documents opened through PDFium.
class Document {
  public:

    // constructor
    Document();
    
    bool load(VALUE path);
    
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
    //bool subscribeToPage(Page* page);
    FPDF_DOCUMENT document;
    bool opened;
    bool ready_to_be_freed;
    //std::unordered_set<Page*> open_pages;
};

static void destroy_document_when_safe(Document* document);

VALUE initialize_document_internals(int arg_count, VALUE* args, VALUE self);
VALUE document_allocate(VALUE rb_PDFium_Document);

#endif // __DOCUMENT_H__
