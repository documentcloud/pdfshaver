#include "page.h"
#include <FreeImage.h>

/********************************************
* C++ Page definition
*********************************************/

Page::Page() { this->opened = false; }

Page::~Page() {
  if (this->opened) {
    this->unload();
    this->document->notifyPageClosed(this);
  }
}

void Page::initialize(Document* document, int page_index) {
  this->document = document;
  this->page_index = page_index;
}

bool Page::load() {
  if (!this->opened) {
    this->fpdf_page = FPDF_LoadPage(this->document->fpdf_document, this->page_index);
    this->document->notifyPageOpened(this);
    this->opened = true;
  }
  return this->opened;
}

void Page::unload() {
  if (this->opened){ FPDF_ClosePage(this->fpdf_page); }
  this->opened = false;
}

double Page::width(){ return FPDF_GetPageWidth(this->fpdf_page); }
double Page::height(){ return FPDF_GetPageHeight(this->fpdf_page); }
double Page::aspect() { return width() / height(); }

bool Page::render(char* path, int width, int height) {
  // If no height or width is supplied, render at natural dimensions.
  if (!width && !height) {
    width  = (int)(this->width());
    height = (int)(this->height());
  }
  // When given only a height or a width, 
  // infer the other by preserving page aspect ratio.
  if ( width && !height) { height = width  / this->aspect(); }
  if (!width &&  height) { width  = height * this->aspect(); }
  //printf("Derp? %d, %d\n", width, height);
  
  // Create bitmap.  width, height, alpha 1=enabled,0=disabled
  bool alpha = false;
  FPDF_BITMAP bitmap = FPDFBitmap_Create(width, height, alpha);
  if (!bitmap) { return false; }

  // fill all pixels with white for the background color
  FPDFBitmap_FillRect(bitmap, 0, 0, width, height, 0xFFFFFFFF);

  // Render a page to a bitmap in RGBA format
  // args are: *buffer, page, start_x, start_y, size_x, size_y, rotation, and flags
  // flags are:
  //      0 for normal display, or combination of flags defined below
  //   0x01 Set if annotations are to be rendered
  //   0x02 Set if using text rendering optimized for LCD display
  //   0x04 Set if you don't want to use GDI+
  int start_x = 0;
  int start_y = 0;
  int rotation = 0;
  int flags = FPDF_PRINTING; // A flag defined in PDFium's codebase.
  FPDF_RenderPageBitmap(bitmap, this->fpdf_page, start_x, start_y, width, height, rotation, flags);

  // The stride holds the width of one row in bytes.  It may not be an exact
  // multiple of the pixel width because the data may be packed to always end on a byte boundary
  int stride = FPDFBitmap_GetStride(bitmap);

  // Safety checks to make sure that the bitmap
  // is properly sized and can be safely manipulated
  bool bitmapIsntValid = (
    (stride < 0) || 
    (width > INT_MAX / height) || 
    ((stride * height) > (INT_MAX / 3))
  );
  if (bitmapIsntValid){
      FPDFBitmap_Destroy(bitmap);
      return false;
  }

  // Read the FPDF bitmap into a FreeImage bitmap.
  unsigned bpp        = 32;
  unsigned red_mask   = 0xFF0000;
  unsigned green_mask = 0x00FF00;
  unsigned blue_mask  = 0x0000FF;
  bool     topdown    = true;
  FIBITMAP *raw = FreeImage_ConvertFromRawBits(
    (BYTE*)FPDFBitmap_GetBuffer(bitmap), width, height, stride, bpp, red_mask, green_mask, blue_mask, topdown);

  // at this point we're done with the FPDF bitmap and can destroy it.
  FPDFBitmap_Destroy(bitmap);

  // Conversion to jpg or gif require that the bpp be set to 24
  // since we're not exporting using alpha transparency above in FPDFBitmap_Create
  FIBITMAP *image = FreeImage_ConvertTo24Bits(raw);
  FreeImage_Unload(raw);

  // figure out the desired format from the file extension
  FREE_IMAGE_FORMAT format = FreeImage_GetFIFFromFilename(path);

  bool success = false;
  if ( FIF_GIF == format ){
      // Gif requires quantization to drop to 8bpp
      FIBITMAP *gif = FreeImage_ColorQuantize(image, FIQ_WUQUANT);
      success = FreeImage_Save(FIF_GIF, gif, path, GIF_DEFAULT);
      FreeImage_Unload(gif);
  } else {
      // All other formats should be just a save call
      success = FreeImage_Save(format, image, path, 0);
  }

  // unload the image
  FreeImage_Unload(image);

  return success;
}

/********************************************
* Ruby class definition and initialization
*********************************************/

void Define_Page() {
  // Get the PDFShaver namespace and get the `Page` class inside it.
  VALUE rb_PDFShaver = rb_const_get(rb_cObject, rb_intern("PDFShaver"));
  VALUE rb_PDFShaver_Page = rb_const_get(rb_PDFShaver, rb_intern("Page"));
  
  rb_define_alloc_func(rb_PDFShaver_Page, *page_allocate);
  
  rb_define_method(rb_PDFShaver_Page, "render", CPP_RUBY_METHOD_FUNC(page_render), -1);
  rb_define_private_method(rb_PDFShaver_Page, "initialize_page_internals", 
                            CPP_RUBY_METHOD_FUNC(initialize_page_internals),-1);
  rb_define_private_method(rb_PDFShaver_Page, "load_data",   CPP_RUBY_METHOD_FUNC(page_load_data), 0);
  rb_define_private_method(rb_PDFShaver_Page, "unload_data", CPP_RUBY_METHOD_FUNC(page_unload_data), 0);
}

VALUE page_allocate(VALUE rb_PDFShaver_Page) {
  Page* page = new Page();
  return Data_Wrap_Struct(rb_PDFShaver_Page, NULL, destroy_page, page);
}

VALUE page_load_data(VALUE self) {
  Page* page;
  Data_Get_Struct(self, Page, page);
  if (! page->load() ) { rb_raise(rb_eRuntimeError, "Unable to load page data"); }
  rb_ivar_set(self, rb_intern("@extension_data_is_loaded"),  Qtrue);
  rb_ivar_set(self, rb_intern("@width"),  INT2FIX(page->width()));
  rb_ivar_set(self, rb_intern("@height"), INT2FIX(page->height()));
  rb_ivar_set(self, rb_intern("@aspect"), rb_float_new(page->aspect()));
  return Qtrue;
}

VALUE page_unload_data(VALUE self) {
  Page* page;
  Data_Get_Struct(self, Page, page);
  page->unload();
  rb_ivar_set(self, rb_intern("@extension_data_is_loaded"),  Qfalse);
  return Qtrue;
}

//bool page_render(int arg_count, VALUE* args, VALUE self) {
VALUE page_render(int arg_count, VALUE* args, VALUE self) {
  VALUE path, options;
  int width = 0, height = 0;

  int number_of_args = rb_scan_args(arg_count, args, "1:", &path, &options);
  if (arg_count > 1) {
    VALUE rb_width  = rb_hash_aref(options, ID2SYM(rb_intern("width")));
    VALUE rb_height = rb_hash_aref(options, ID2SYM(rb_intern("height")));
    
    if (!(NIL_P(rb_width))) {
      if (FIXNUM_P(rb_width)) { width = FIX2INT(rb_width); } 
      else { rb_raise(rb_eArgError, ":width must be a integer"); }
    }
    if (!(NIL_P(rb_height))) {
      if (FIXNUM_P(rb_height)) { height = FIX2INT(rb_height); } 
      else { rb_raise(rb_eArgError, ":height must be a integer"); }
    }
  }

  FREE_IMAGE_FORMAT format = FreeImage_GetFIFFromFilename(StringValuePtr(path));
  if (format == FIF_UNKNOWN) { rb_raise(rb_eArgError, "can't save to unrecognized image format"); }
  
  Page* page;
  Data_Get_Struct(self, Page, page);
  
  VALUE output = (page->render(StringValuePtr(path), width, height) ? Qtrue : Qfalse);
  return output;
}

VALUE initialize_page_internals(int arg_count, VALUE* args, VALUE self) {
  // use Ruby's argument scanner to pull out a required
  VALUE rb_document, page_index, options;
  int number_of_args = rb_scan_args(arg_count, args, "21", &rb_document, &page_index, &options);
  
  Document* document;
  Data_Get_Struct(rb_document, Document, document);
  
  Page* page;
  Data_Get_Struct(self, Page, page);
  
  page->initialize(document, FIX2INT(page_index));
  page_load_data(self);
  
  return self;
}

static void destroy_page(Page* page) { delete page; }
