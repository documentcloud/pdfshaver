#ifndef __PDFIUM_RUBY_H__
#define __PDFIUM_RUBY_H__

extern "C" {
  #include "ruby.h"
}

// Inspired by https://github.com/jasonroelofs/rice/blob/1740a6d12c99fce8c21eda3c5385738318ab9172/rice/detail/ruby.hpp#L33-L37
// Casts C functions into a type that C++ is happy calling
extern "C" typedef VALUE (*CPP_RUBY_METHOD_FUNC)(ANYARGS);

void Define_Document();
void Define_Page();
void Define_PageSet();

// helper function for printing string literals for debugging purposes
void inline ruby_puts_cstring(const char* str) { rb_funcall(rb_cObject, rb_intern("puts"), 1, rb_str_new_cstr(str)); }
void inline ruby_puts_values(VALUE str){ rb_funcall(rb_cObject, rb_intern("puts"), 1, str); }

#endif