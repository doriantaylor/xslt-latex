# `latex.xsl`: You Love to See It

OK folks this is my highly-opinionated (X)HTML to LaTeX transform. It
is a work in progress, but the ultimate goal is to be able to turn
collections of Web pages into nice-looking PDFs.

## Getting Started

You will need to `make fetch` before you can do anything, because this
thing uses my [RDFa](https://github.com/doriantaylor/rdfa-xslt) and
[transclusion](https://github.com/doriantaylor/xslt-transclusion) XSLT
libraries, as well as [XSLTSL](http://xsltsl.sourceforge.net/).

## Formatting your (X)HTML

The RDFa and transclusion libraries both require the `<base href="…"/>`
tag to be set on all resources *to the URLs where they actually are*,
because XSLT otherwise has no way of knowing where anything is.

This transform also takes advantage of RDFa 1.1, and will resolve
certain embedded metadata:

* `rdf:type` for `\documentclass{}`
* `dct:creator` for `\author{}`
* `dct:issued`, `dct:created`, `dct:date` for `\date{}`
* `dct:abstract` for `\abstract{}`

The following RDF classes map to the following document types:

* `bibo:Book` and subclasses map to `\documentclass{book}`
* `bibo:Report`, `bibo:Manual`, `bibo:Specification`, `bibo:Standard`,
  all map to `\documentclass{report}`
* `bibo:PersonalCommunicationDocument` and subclasses map to
  `\documentclass{letter}`
* `bibo:Article` and everything else maps to `\documentclass{article}`

Section levels are handled automatically, with `book` and `report`
defaulting to `\chapter`, and everything else defaulting to
`\section`. You can set the default section to `\part` by making the
type a `bibo:Collection` or `bibo:MultiVolumeBook`.

> (I am not in love with that last mapping but needed some way to
> express it.)

## Running the Beast

You will have to run `xsltproc` like so, in order to resolve the
embedded URI references:

```bash
SGML_CATALOG_FILES=./catalog.xml xsltproc --catalogs latex.xsl whatever.xhtml
```

If you want to access the output in a browser, you can make the
beginning of your document look like this:

```xml
<?xml version="1.0" encoding="utf-8"?>
<?xml-stylesheet type="text/xsl" href="latex"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">...
```

…assuming your server is set up to clip file extensions. If not,
you'll have to go in and add `.xsl` to everything.

## Copyright & License

©2018-2021 [Dorian Taylor](https://doriantaylor.com/)

This software is provided under
the [Apache License, 2.0](https://www.apache.org/licenses/LICENSE-2.0).
