fetch :
	curl -LO https://raw.githubusercontent.com/doriantaylor/rdfa-xslt/b4d8253111e16055e86c0e4ee735b47cdd0dc24b/rdfa.xsl
	curl -LO https://github.com/doriantaylor/xslt-transclusion/blob/52ecbfad9088006b850a7540fbd85348af8466a7/transclude.xsl
	curl -LO https://prdownloads.sourceforge.net/xsltsl/xsltsl-1.2.1.tar.gz
	tar zxf xsltsl-1.2.1.tar.gz
	rm xsltsl-1.2.1.tar.gz
	mv xsltsl-1.2.1 xsltsl

clean :
	rm -rf rdfa.xsl transclude.xsl xsltsl*
