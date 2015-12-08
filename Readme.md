# PDFShaver

Shave pages off of PDFs as images.

### Examples

    require 'pdfshaver'
    # open a document!
    document = PDFShaver::Document.new('./path/to/document.pdf')
    # Iterate through its pages
    landscape_pages = document.pages.select{ |page| page.aspect > 1 }
    landscape_pages.each{ |page| page.render("./page_#{page.number}.gif") }

copyright 2015 Ted Han, Nathan Stitt & DocumentCloud

## Installation

PDFShaver is distributed as a Ruby gem.  Once you have its dependencies installed, all you have to do is type `gem install pdfshaver` (although in some cases you'll need to stick a `sudo` before the command).

PDFShaver depends on [Google Chrome's `PDFium` library][pdfium], and, for now, installing `PDFium` takes a little bit of doing.

[pdfium]: https://code.google.com/p/pdfium/

### Getting PDFium and FreeImage

#### On Ubuntu/Debian

We've built a .deb that you can download and install like so:

```sh
wget 'https://assets.documentcloud.org/pdfium/libpdfium-dev_20151208.015427_amd64.deb'
sudo dpkg -i libpdfium-dev_20151208.015427_amd64.deb
```

And install FreeImage and FreeType:

`sudo apt-get install libfreeimage-dev libfreetype6-dev`

#### On OSX

You can use homebrew to install pdfium's current code using our Homebrew formula:

`brew install --HEAD https://raw.githubusercontent.com/knowtheory/homebrew/c35937bc14e9829d2e94100b9120273b1c496474/Library/Formula/pdfium.rb`

Then install FreeImage:

`brew install freeimage`

#### On Windows

Unfortunately, we don't have a Windows package yet.

#### On other Linux/Unix systems

Sorry we don't have a release for your OS but we'd be happy to talk to you about how we packaged PDFium for OSX and Ubuntu if you'd like to help package PDFium for your distribution/os!

### Install PDFShaver

`gem install pdfshaver` (you may have to use `sudo gem` instead of just `gem`)
