# PDFShaver

# N.B. THIS IS A WORK IN PROGRESS

Shave pages off of PDFs as images

### Examples

    require 'pdfshaver'
    # open a document!
    document = PDFShaver::Document.new('./path/to/document.pdf')
    # Iterate through its pages
    landscape_pages = document.pages.select{ |page| page.aspect > 1 }
    landscape_pages.each{ |page| page.render("./page_#{page.number}.gif") }

copyright 2015 Ted Han, Nathan Stitt & DocumentCloud

## Installation

PDFShaver is distributed as a Ruby gem.  Once you have it's dependencies installed, all you have to do is type `gem install pdfshaver` (although in some cases you'll need to stick a `sudo` before the command).

PDFShaver depends on [Google Chrome's `PDFium` library][pdfium], and for now, installing `PDFium` takes a little bit of doing.

[pdfium]: https://code.google.com/p/pdfium/

In order install PDFium, you'll need Python, a C++ compiler, `git` and subversion.  All of these tools should be available for your operating system.

### OSX


#### C++ compiler
Check whether you have the xcode command line tools installed by typing `xcode-select -p`.  If this command returns something like `/Applications/Xcode.app/Contents/Developer` then you have the command line tools installed already.

If you do not already have the xcode commandline tools installed running `xcode-select --install` will start you off down the correct path.

-------------------

At this point, it may be convenient to install Homebrew.

#### Python

If you're using a recent Mac, you should already have Python 2.7 installed on your machine.  You can check what version of Python you're running by typing `python --version` into your terminal.  If you don't have a recent version of python (version 2.7 or greater) installed, you'll 

#### `git`

If you have homebrew installed simply type `brew install git`

#### subversion

You should already have subversion installed on your mac by default

### Linux (we'll assume ubuntu or debian)

#### C++ Compiler
`sudo apt-get install build-essential`
#### `git`
`sudo apt-get install git`
#### subversion
`sudo apt-get install subversion`

### Getting PDFium's dependencies

If you have any trouble check [PDFium's build instructions](https://code.google.com/p/pdfium/wiki/Build) for the most up to date instructions.



### Getting the PDFium code

`git clone https://pdfium.googlesource.com/pdfium`


