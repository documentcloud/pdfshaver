require "mkmf"
require 'rbconfig'
# List directories to search for PDFium headers and library files to link against
def append_pdfium_directory_to paths
  paths.map{ |dir| [File.join(dir, 'pdfium'), File.join(dir, 'pdfium', 'fpdfsdk', 'include')] }.flatten + paths
end

LIB_DIRS    = append_pdfium_directory_to %w[
  /usr/local/lib/
  /usr/lib/
]
HEADER_DIRS = append_pdfium_directory_to %w[
  /usr/local/include/
  /usr/include/
]

# Tell ruby we want to search in the specified paths
dir_config("pdfium", HEADER_DIRS, LIB_DIRS)

LIB_FILES= %w[
  pdfium
  bigint
  freetype
  fpdfdoc
  fpdftext
  formfiller
  javascript
  v8_base
  v8_libbase
  v8_snapshot
  v8_libplatform
  jsapi
  icui18n
  icuuc
  icudata
  pdfwindow
  fxedit
  fxcodec
  fxcrt
  fpdfdoc
  fpdfapi
  fdrm
  fxge
  pthread
]
LIB_FILES.each do | lib |
  have_library(lib) or abort "Couldn't find library lib#{lib} in #{LIB_DIRS.join(', ')}"
end

# Core Graphics needed on macs to run PDFium.
if `uname`.chomp == 'Darwin' then

  FRAMEWORKS = %w{AppKit CoreFoundation}

  $LDFLAGS << FRAMEWORKS.map { |f| " -framework #{f}" }.join
end

create_makefile "pdfium_ruby"
