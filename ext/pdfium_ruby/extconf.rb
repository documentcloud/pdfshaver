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
  /usr/local/lib/
  /usr/lib/
]
header_dirs = %w[
  /usr/local/include/
  /usr/include/
]
header_paths = [
  'pdfium',
  File.join('pdfium', 'core', 'include'),
  File.join('pdfium', 'fpdfsdk', 'include'),
  File.join('pdfium', 'third_party', 'base', 'numerics')
]
LIB_DIRS    = append_search_paths_to lib_dirs, ['pdfium']
HEADER_DIRS = append_search_paths_to header_dirs, header_paths

# Tell ruby we want to search in the specified paths
dir_config("pdfium", HEADER_DIRS, LIB_DIRS)

LIB_FILES= %w[
  javascript
  bigint
  freetype
  fpdfdoc
  fpdftext
  formfiller
  pdfwindow
  fxedit
  fxcrt
  fxcodec
  fpdfdoc
  fdrm
  fxge
  fpdfapi
  freetype
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
