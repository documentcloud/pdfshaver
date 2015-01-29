#ifndef __PAGE_H__
#define __PAGE_H__

// forward declaration since Page/Document classes are interdependent
class Document;
#include "pdfium_ruby.h"
#include "document.h"

class Page {
  public:
    Page(Document* document, int page_number);
    
    bool render();
    
    float aspect();
    
    double width();
    double height();
    
    ~Page();
    
  private:
    Document *document;
    int page_number;
    FPDF_PAGE page;
};

void Define_Page();
VALUE initialize_page_internals(int arg_count, VALUE* args, VALUE self);

#endif