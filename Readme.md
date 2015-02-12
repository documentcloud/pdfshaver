# PDFShaver

Shave pages off of PDFs as images

### N.B. This is a work in process

### Examples

    require 'pdfshaver'
    document = PDFShaver::Document.new('./path/to/document.pdf')
    landscape_pages = document.pages.select{ |page| page.aspect > 1 }
    landscape_pages.each{ |page| page.render("./page_#{page.number}.gif") }

copyright 2015 Ted Han, Nathan Stitt & DocumentCloud