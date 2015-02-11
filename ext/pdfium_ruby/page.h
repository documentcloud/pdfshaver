#ifndef __PAGE_H__
#define __PAGE_H__

// forward declaration since Page/Document classes are interdependent
class Document;
#include "pdfium_ruby.h"
#include "document.h"

class Page {
  public:
    Page();
    
    bool load(Document* document, int page_number);
    
    double width();
    double height();
    double aspect();
    
    bool render(char* path, int width, int height);
    
    ~Page();
    
  private:
    int page_index;
    bool opened;
    Document *document;
    FPDF_PAGE fpdf_page;
};

void Define_Page();
VALUE initialize_page_internals(int arg_count, VALUE* args, VALUE self);
VALUE page_render(int arg_count, VALUE* args, VALUE self);
VALUE page_allocate(VALUE rb_PDFShaver_Page);
static void destroy_page(Page* page);

#endif