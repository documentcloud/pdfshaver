require "mkmf"
require 'rbconfig'

# Take a set of directories to search (usually system paths)
# and append the paths that we expect to find PDFium's peices.
def append_search_paths_to search_dirs, search_suffixes
  search_dirs.map do |dir|
    search_suffixes.map{ |path| File.join(dir, path) }
  end.flatten + search_dirs
end

lib_dirs = %w[
  /usr/local/Cellar/pdfium/HEAD/lib
  /usr/local/lib/pdfium
  /usr/lib/pdfium
  /usr/local/lib
  /usr/lib
]
header_dirs = %w[
  /usr/local/Cellar/pdfium/HEAD/include
  /usr/local/include/pdfium
  /usr/include/pdfium
  /usr/local/include/
  /usr/include/
]
header_paths = [
  'public',
  File.join('core', 'include'),
  File.join('fpdfsdk', 'include'),
  File.join('third_party', 'base', 'numerics')
]
LIB_DIRS    = append_search_paths_to lib_dirs, ['third_party']
HEADER_DIRS = append_search_paths_to header_dirs, header_paths

# Tell ruby we want to search in the specified paths
dir_config("pdfium", HEADER_DIRS, LIB_DIRS)

# lib order needs to be in dependency loaded order, or will not link properly.
LIB_FILES= %w[
  javascript
  bigint
  fx_freetype
  fx_agg
  fx_lcms2
  fx_libjpeg
  fx_libopenjpeg
  fx_zlib
  fxedit
  fxcrt
  fxcodec
  fxge
  fpdfdoc
  fpdftext
  formfiller
  pdfwindow
  fpdfdoc
  fdrm
  fpdfapi
  pdfium
  pthread
  freeimage
]

LIB_FILES.each do | lib |
  have_library(lib) or abort "Couldn't find library lib#{lib} in #{LIB_DIRS.join(', ')}"
end

$CPPFLAGS += " -fPIC -std=c++11 -Wall"
if RUBY_PLATFORM =~ /darwin/
  have_library('objc')
  FRAMEWORKS = %w{AppKit CoreFoundation}
  $LDFLAGS << FRAMEWORKS.map { |f| " -framework #{f}" }.join
end

if ENV['DEBUG'] == '1'
  $defs.push "-DDEBUG=1"
  $CPPFLAGS += " -g"
else
  $CPPFLAGS += " -O2"
end

create_makefile "pdfium_ruby"
