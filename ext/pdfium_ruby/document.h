#ifndef __DOCUMENT_H__
#define __DOCUMENT_H__

// forward declaration since Page/Document classes are interdependent
class Page;
#include "pdfium_ruby.h"
#include "fpdf_ext.h"
//#include "core/include/fpdfapi/fpdf_parser.h"
#include "page.h"
#include <unordered_set>

// C++ Class to wrap lifecycle of
// PDF Documents opened through PDFium.
class Document {
  public:
    FPDF_DOCUMENT fpdf_document;

    // constructor
    Document();
    
    int load(VALUE path);
    
    // wrapper for PDFium's pageCount
    int length();
    
    bool isValid();
    
    // flag to set instances as ready to be disposed of
    // pending ensuring all its pages have been first closed.
    void flagDocumentAsReadyForRelease();
    
    // a guard for the destructor.
    void destroyUnlessPagesAreOpen();
    
    void notifyPageClosed(Page* page);
    void notifyPageOpened(Page* page);
    
    // destructor
    ~Document();
    
  private:
    //bool subscribeToPage(Page* page);
    bool opened;
    bool ready_to_be_freed;
    std::unordered_set<Page*> open_pages;
};

VALUE initialize_document_internals(int arg_count, VALUE* args, VALUE self);
VALUE document_allocate(VALUE rb_PDFShaver_Document);
//static void destroy_document_when_safe(Document* document);
void document_handle_parse_status(int status, VALUE path);  
#endif // __DOCUMENT_H__
