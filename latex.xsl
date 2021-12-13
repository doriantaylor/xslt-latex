<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:rdfa="http://www.w3.org/ns/rdfa#"
                xmlns:str="http://xsltsl.org/string"
                xmlns:uri="http://xsltsl.org/uri"
                xmlns:dt="http://xsltsl.org/date-time"
                xmlns:xc="https://makethingsmakesense.com/asset/transclude#"
                xmlns:z="urn:x-dummy:data"
                exclude-result-prefixes="rdfa str uri dt xc z">

<xsl:import href="/asset/xsltsl/string"/>  
<xsl:import href="/asset/xsltsl/uri"/>  
<xsl:import href="/asset/xsltsl/date-time"/>  
<xsl:import href="/asset/rdfa"/>  
<xsl:import href="/asset/transclude"/>  

<xsl:output method="text" media-type="text/x-tex" encoding="utf-8"/>

<xsl:key name="id" match="html:*[@id]" use="@id"/>
<xsl:key name="main" match="html:main[not(@hidden)]" use="''"/>
<xsl:key name="article" match="html:article" use="''"/>
<xsl:key name="section" match="html:section" use="''"/>

<xsl:key name="has-main" match="html:main[not(@hidden)]" use="''"/>
<xsl:key name="has-article" match="html:article[ancestor::html:main[not(@hidden)]]|html:article[ancestor::html:body[not(descendant::html:main)]]" use="''"/>

<xsl:variable name="BIBO" select="'http://purl.org/ontology/bibo/'"/>
<xsl:variable name="DCT" select="'http://purl.org/dc/terms/'"/>
<xsl:variable name="FOAF" select="'http://xmlns.com/foaf/0.1/'"/>

<xsl:variable name="DEBUG" select="true()"/>
<xsl:variable name="xc:DEBUG" select="true()"/>

<z:data>
  <z:char id="#" replace="\#"/>
  <z:char id="$" replace="\$"/>
  <z:char id="%" replace="\%"/>
  <z:char id="&amp;" replace="\&amp;"/>
  <!--<z:char id="'" replace="\$"/>-->
  <z:char id="~" replace="\~{}"/>
  <z:char id="&lt;" replace="\textless{}"/>
  <z:char id="&gt;" replace="\textgreater{}"/>
  <z:char id="\" replace="\textbackslash{}"/>
  <z:char id="_" replace="\_"/>
  <z:char id="{" replace="\{"/>
  <z:char id="}" replace="\}"/>
  <z:char id="à" replace="\`{a}"/>
  <z:char id="é" replace="\'{e}"/>
  <z:char id="ï" replace="\&quot;{i}"/>
  <z:char id="&#x2013;" replace="--"/>
  <z:char id="&#x2014;" replace="---"/>
  <z:char id="&#x2026;" replace="\ldots{}"/>
  <z:char id="&#x2190;" replace="$\leftarrow$"/>
  <z:char id="&#x2192;" replace="$\rightarrow$"/>
</z:data>

<xsl:variable name="Z-DATA" select="document('')/xsl:stylesheet/z:data"/>
<xsl:variable name="BADCHARS">
  <xsl:for-each select="$Z-DATA/z:char">
    <xsl:value-of select="@id"/>
  </xsl:for-each>
</xsl:variable>

<z:sections>
  <z:section>part</z:section>
  <z:section>chapter</z:section>
  <z:section>section</z:section>
  <z:section>subsection</z:section>
  <z:section>subsubsection</z:section>
  <z:section>paragraph</z:section>
  <z:section>subparagraph</z:section>
</z:sections>

<xsl:template match="@id" mode="label">
<xsl:text>\label{</xsl:text><xsl:value-of select="."/>
<xsl:text>}&#x0a;</xsl:text>
</xsl:template>


<xsl:template match="text()" name="process-text">
  <xsl:param name="text" select="."/>
  <xsl:param name="is-uri" select="false()"/>
  <xsl:param name="depth" select="0"/>
<xsl:choose>
  <xsl:when test="string-length($text) = 0"/>
  <xsl:when test="string-length($text) != string-length(translate($text, $BADCHARS, ''))">
    <xsl:variable name="match-pos">
      <xsl:variable name="_">
        <xsl:for-each select="$Z-DATA/z:char">
          <!--<xsl:message><xsl:value-of select="@id"/></xsl:message>-->
          <xsl:if test="contains($text, string(@id))">
            <xsl:value-of select="concat(' ', position(), ' ')"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="__" select="normalize-space($_)"/>
      <xsl:choose>
        <xsl:when test="contains($__, ' ')">
          <xsl:value-of select="substring-before($__, ' ')"/>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="$__"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--<xsl:message>lol wut <xsl:value-of select="$match-pos"/></xsl:message>-->

    <xsl:variable name="char" select="$Z-DATA/z:char[number($match-pos)]"/>

    <!--<xsl:variable name="replace" select="$char/@replace"/>-->

    <xsl:if test="not($char)">
      <xsl:message terminate="yes">lol <xsl:value-of select="$match-pos"/>
      </xsl:message>
    </xsl:if>

    <!--<xsl:message>char <xsl:value-of select="$char/@id"/></xsl:message>-->

    <xsl:variable name="before" select="substring-before($text, $char/@id)"/>
    <xsl:variable name="after" select="substring-after($text, $char/@id)"/>

    <xsl:if test="string-length($before) != 0">
      <!--<xsl:message>BEFORE <xsl:value-of select="$depth"/>: <xsl:value-of select="$before"/></xsl:message>-->
      <xsl:call-template name="process-text">
        <xsl:with-param name="text" select="$before"/>
        <xsl:with-param name="is-uri" select="$is-uri"/>
        <xsl:with-param name="depth" select="$depth + 1"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$is-uri and string($char/@id) = '~'">
        <xsl:value-of select="$char/@id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$char/@replace"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="string-length($after) != 0">
      <!--<xsl:message>AFTER <xsl:value-of select="$depth"/>: <xsl:value-of select="$after"/></xsl:message>-->
      <xsl:call-template name="process-text">
        <xsl:with-param name="text" select="$after"/>
        <xsl:with-param name="is-uri" select="$is-uri"/>
        <xsl:with-param name="depth" select="$depth + 1"/>
      </xsl:call-template>
    </xsl:if>
    
  </xsl:when>
  <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="html:title">
<xsl:text>\title{</xsl:text>
<xsl:apply-templates/>
<xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template match="html:head">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="html:title"/>

  <xsl:variable name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="debug" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="author">
    <xsl:variable name="_">
      <xsl:apply-templates select="." mode="rdfa:object-resources">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="predicate" select="concat($DCT, 'creator')"/>
        <xsl:with-param name="base" select="$base"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="string-length(normalize-space($_))">
      <xsl:variable name="__">
        <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
          <xsl:with-param name="subject" select="$_"/>
          <xsl:with-param name="predicate" select="concat($FOAF, 'name')"/>
          <xsl:with-param name="base" select="$base"/>
        </xsl:apply-templates>
      </xsl:variable>
      <xsl:value-of select="normalize-space(substring-before($__, $rdfa:UNIT-SEP))"/>
    </xsl:if>
  </xsl:variable>

  <xsl:if test="$author">
    <xsl:text>\author{</xsl:text>
    <xsl:value-of select="$author"/>
    <xsl:text>}&#x0a;</xsl:text>
  </xsl:if>

  <xsl:variable name="issued">
    <xsl:variable name="_">
      <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="predicate" select="concat($DCT, 'issued')"/>
        <xsl:with-param name="base" select="$base"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:value-of select="normalize-space(substring-before($_, $rdfa:UNIT-SEP))"/>
  </xsl:variable>

  <xsl:variable name="created">
    <xsl:variable name="_">
      <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
        <xsl:with-param name="subject" select="$subject"/>
        <xsl:with-param name="predicate" select="concat($DCT, 'created')"/>
        <xsl:with-param name="base" select="$base"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:value-of select="normalize-space(substring-before($_, $rdfa:UNIT-SEP))"/>
  </xsl:variable>

  <xsl:message>issued: <xsl:value-of select="$issued"/>, created <xsl:value-of select="$created"/></xsl:message>

  <xsl:if test="string-length($issued) or string-length($created)">
    <xsl:text>\date{</xsl:text>
    <xsl:call-template name="dt:format-date-time">
      <xsl:with-param name="format" select="'%A, %B %e, %Y'"/>
      <xsl:with-param name="xsd-date-time">
        <xsl:choose>
          <xsl:when test="string-length($issued)">
            <xsl:value-of select="$issued"/>
          </xsl:when>
          <xsl:when test="string-length($created)">
            <xsl:value-of select="$created"/>
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>}&#x0a;</xsl:text>
  </xsl:if>

</xsl:template>

<xsl:template match="html:meta[@name='author']">
<xsl:text>\author{</xsl:text>
<xsl:call-template name="process-text">
  <xsl:with-param name="text" select="@content"/>
</xsl:call-template>
<xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template match="html:meta[@name='date']">
<xsl:text>\date{</xsl:text>
<xsl:call-template name="process-text">
  <xsl:with-param name="text" select="@content"/>
</xsl:call-template>
<xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template match="/html:html">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:get-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite">
    <xsl:apply-templates select="." mode="xc:get-rewrites">
      <xsl:with-param name="base" select="$base"/>
    </xsl:apply-templates>
  </xsl:param>
  <xsl:param name="main" select="false()"/>

  <xsl:variable name="subject">
    <xsl:apply-templates select="." mode="rdfa:get-subject">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="debug" select="false()"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="type">
    <xsl:apply-templates select="." mode="rdfa:object-resources">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="predicate" select="$rdfa:RDF-TYPE"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:variable name="tp" select="concat(' ', normalize-space($type), ' ')"/>
  <xsl:variable name="is-report" select="contains($tp, concat(' ', $BIBO, 'Manual ')) or contains($tp, concat(' ', $BIBO, 'Report ')) or contains($tp, concat(' ', $BIBO, 'Specification ')) or contains($tp, concat(' ', $BIBO, 'Standard '))"/>
  <xsl:variable name="is-book" select="contains($tp, concat(' ', $BIBO, 'Book ')) or contains($tp, concat(' ', $BIBO, 'MultiVolumeBook ')) or contains($tp, concat(' ', $BIBO, 'Thesis '))"/>
  <xsl:variable name="is-multi" select="contains($tp, concat(' ', $BIBO, 'Collection ')) or contains($tp, concat(' ', $BIBO, 'MultiVolumeBook '))"/>

  <xsl:variable name="heading">
    <xsl:choose>
      <xsl:when test="$is-multi"><xsl:value-of select="1"/></xsl:when>
      <!-- ideally the condition should be if the thing contains chapters -->
      <xsl:when test="$is-book or $is-report">
        <xsl:value-of select="2"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="3"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$DEBUG">
    <xsl:message>type(s): <xsl:value-of select="$type"/>; heading level: <xsl:value-of select="$heading"/>; base: <xsl:value-of select="$base"/></xsl:message>
  </xsl:if>

  <xsl:variable name="has-main" select="key('main', '')[1]"/>
  <xsl:variable name="has-article" select="key('article', '')[1]"/>
  <xsl:variable name="has-section" select="key('section', '')[1]"/>

<xsl:variable name="document-class">
  <xsl:choose>
    <xsl:when test="$heading &gt; 2"><xsl:value-of select="'article'"/></xsl:when>
    <xsl:when test="$is-book or $is-multi"><xsl:value-of select="'book'"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="'report'"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:text>\documentclass[letterpaper,twoside,10pt]{</xsl:text>
<xsl:value-of select="$document-class"/><xsl:text>}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{palatino}
\usepackage{inconsolata}
\usepackage[bookmarks=true,unicode=true,colorlinks=false,hidelinks=true]{hyperref}
\usepackage{textcomp}
\usepackage{gensymb}
\usepackage{marginnote}
\usepackage{sidenotes}
\usepackage{graphicx}
\usepackage{enumitem}
\usepackage{xltabular}
\usepackage{multirow}
%\usepackage{dblfnote}
</xsl:text>
<xsl:if test="not($is-book or $is-multi)">
<xsl:text>
\renewcommand{\abstractname}{Executive Summary}
</xsl:text>
</xsl:if>

<xsl:apply-templates select="html:head">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>

<xsl:text>
\setlength{\parskip}{1em}
\setlength{\parindent}{0em}
\begin{document}
\maketitle
</xsl:text>

<xsl:variable name="abstract">
  <xsl:variable name="_">
    <xsl:apply-templates select="." mode="rdfa:object-literal-quick">
      <xsl:with-param name="subject" select="$subject"/>
      <xsl:with-param name="predicate" select="concat($DCT, 'abstract')"/>
      <xsl:with-param name="base" select="$base"/>
    </xsl:apply-templates>
  </xsl:variable>
  <xsl:value-of select="substring-before($_, $rdfa:UNIT-SEP)"/>
</xsl:variable>

<xsl:if test="normalize-space($abstract) != ''">
<xsl:text>
\begin{abstract}

</xsl:text>
<xsl:value-of select="$abstract"/>

<xsl:text>

\end{abstract}

</xsl:text>
</xsl:if>

<xsl:if test="$heading &lt; 3">
<xsl:text>
\tableofcontents

</xsl:text>
</xsl:if>

<xsl:apply-templates select="($has-article|$has-main|html:body)[1]">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>

<!--<xsl:apply-templates select="html:html/html:body/html:article[position() != 1]/html:section">
</xsl:apply-templates>-->
<xsl:text>
\end{document}</xsl:text>
</xsl:template>

<!-- throw this in for client project lol -->
<xsl:template match="html:input[@value]">
<xsl:value-of select="@value"/>
</xsl:template>

<xsl:template match="html:script[@type='text/javascript']"/>

<xsl:template match="html:*" mode="xc:heading">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="debug" select="$xc:DEBUG"/>

  <xsl:variable name="keyword">
    <xsl:choose>
      <xsl:when test="$heading &lt; 7">
        <xsl:value-of select="document('')/xsl:stylesheet/z:sections/z:section[number($heading)]"/>
      </xsl:when>
      <xsl:otherwise>subparagraph</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$debug">
    <xsl:message>base: <xsl:value-of select="$base"/>, heading level: <xsl:value-of select="$heading"/>, keyword: <xsl:value-of select="$keyword"/>, title: <xsl:value-of select="normalize-space(.)"/></xsl:message>
  </xsl:if>

  <xsl:value-of select="concat('\', $keyword, '{')"/>
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>}&#xa;</xsl:text>
</xsl:template>

<xsl:template match="html:section|html:article|html:main|html:body" mode="normal">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="h-elem" select="(html:h1|html:h2|html:h3|html:h4|html:h5|html:h6)[1]"/>

  <xsl:text>&#xa;</xsl:text>

  <xsl:apply-templates select="$h-elem" mode="xc:heading">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:apply-templates select="*[not(self::html:h1|self::html:h2|self::html:h3|self::html:h4|self::html:h5|self::html:h6)]">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading + 1"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="html:section">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:if test="$DEBUG">
    <xsl:message>hmm base: <xsl:value-of select="$base"/>, heading level: <xsl:value-of select="$heading"/></xsl:message>
  </xsl:if>

  <xsl:apply-templates select="." mode="normal">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="html:section[html:script[@src][contains(translate(@type, 'XML', 'xml'), 'xml')]][count(*) = 1][normalize-space(.) = '']">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:message>got here lol</xsl:message>

  <!-- note we don't increment the heading here because i dunno why -->
  <xsl:apply-templates select="html:script">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>

</xsl:template>


<!--
<xsl:template match="html:dl[parent::html:section][not(following-sibling::*)][not(preceding-sibling::*) or preceding-sibling::html:h1|preceding-sibling::html:h2|preceding-sibling::html:h3|preceding-sibling::html:h4|preceding-sibling::html:h5|preceding-sibling::html:h6]" priority="2">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:for-each select="html:dt">
    <xsl:text>\paragraph{</xsl:text>
    <xsl:apply-templates select="node()">
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite"       select="$rewrite"/>
      <xsl:with-param name="main"          select="$main"/>
      <xsl:with-param name="heading"       select="$heading"/>
    </xsl:apply-templates>
    <xsl:text>}
</xsl:text>

<xsl:apply-templates select="@id" mode="label"/>

<xsl:variable name="dt-id" select="generate-id(.)"/>
<xsl:for-each select="following-sibling::html:dd[generate-id(preceding-sibling::html:dt[1]) = $dt-id]">
<xsl:apply-templates select="node()">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
<xsl:text>

</xsl:text>
</xsl:for-each>
</xsl:for-each>
</xsl:template>-->

<xsl:template match="html:p">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:if test="$DEBUG">
    <xsl:message>p base: <xsl:value-of select="$base"/></xsl:message>
  </xsl:if>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
<xsl:text>

</xsl:text>
</xsl:template>

<xsl:template match="html:q">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:text>``</xsl:text>
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>''</xsl:text>
</xsl:template>

<xsl:template match="html:samp">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:text>\texttt{</xsl:text>
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- XXX make this go to refs or something -->
<xsl:template match="html:dfn|html:abbr">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:text>\textsc{</xsl:text>
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>}</xsl:text>
</xsl:template>

<!-- too much trouble :(
<xsl:template match="html:abbr[@title]">
<xsl:text>\textsc{</xsl:text>
<xsl:apply-templates/>
<xsl:text>}\protect\footnote{</xsl:text>
<xsl:call-template name="process-text">
  <xsl:with-param name="text" select="@title"/>
</xsl:call-template>
<xsl:text>}</xsl:text>
</xsl:template>-->

<xsl:template match="html:strong">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:text>\textbf{</xsl:text>
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="html:em">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:text>\emph{</xsl:text>
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="html:code|html:samp|html:kbd">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:text>\texttt{</xsl:text>
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="html:var">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:text>$</xsl:text>
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>$</xsl:text>
</xsl:template>

<xsl:template match="html:ul">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:if test="$DEBUG">
    <xsl:message>ul base: <xsl:value-of select="$base"/></xsl:message>
  </xsl:if>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:text>&#x0a;\begin{itemize}</xsl:text>
  <xsl:if test="ancestor::html:aside[@role='note']">
    <xsl:text>[leftmargin=*]</xsl:text>
  </xsl:if>
  <xsl:text>&#x0a;</xsl:text>
  <xsl:apply-templates select="html:li">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>\end{itemize}&#x0a;&#x0a;</xsl:text>
</xsl:template>

<xsl:template match="html:ol">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:if test="$DEBUG">
    <xsl:message>ol base: <xsl:value-of select="$base"/></xsl:message>
  </xsl:if>

  <xsl:text>&#x0a;\begin{enumerate}&#x0a;</xsl:text>
  <xsl:apply-templates select="html:li">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>\end{enumerate}&#x0a;&#x0a;</xsl:text>
</xsl:template>

<xsl:template match="html:li">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:if test="$DEBUG">
    <xsl:message>li base: <xsl:value-of select="$base"/></xsl:message>
  </xsl:if>

  <xsl:text>\item </xsl:text>
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>

  <xsl:text>&#x0a;</xsl:text>
</xsl:template>

<xsl:template match="html:dl">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:text>&#x0a;\begin{description}[style=nextline]&#x0a;</xsl:text>
  <xsl:apply-templates select="html:dt|html:dd">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>\end{description}&#x0a;</xsl:text>
</xsl:template>

<xsl:template match="html:dt">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:text>\item [</xsl:text>
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:text>]~ </xsl:text>

  <xsl:apply-templates select="@id" mode="label"/>
</xsl:template>

<xsl:template match="html:dd">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
  <xsl:if test="following-sibling::*[1][self::html:dd]">
    <xsl:text> \\</xsl:text>
  </xsl:if>

  <xsl:text>&#x0a;</xsl:text>
</xsl:template>

<xsl:template match="html:table">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

<xsl:variable name="max-cols">
  <xsl:for-each select="html:tr|html:thead/html:tr|html:tbody/html:tr|html:tfoot/html:tr">
    <xsl:sort select="count(html:th|html:td)" data-type="number" order="descending"/>
    <xsl:if test="position() = 1"><xsl:value-of select="count(html:th|html:td)"/></xsl:if>
  </xsl:for-each>
</xsl:variable>

<xsl:variable name="col-spec">
  <xsl:variable name="_" select="(html:tbody/html:tr|html:tr)[count(*) = number($max-cols)][1]"/>
  <xsl:for-each select="$_/html:th|$_/html:td">
    <!--
    <xsl:choose>
      <xsl:when test="local-name() = 'th'">
        <xsl:text>p{</xsl:text>
        <xsl:value-of select="round(1 div number($max-cols) * 80) div 100"/>
        <xsl:text>\textwidth}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>p{</xsl:text>
        <xsl:value-of select="round(1 div number($max-cols) * 80) div 100"/>
        <xsl:text>\textwidth}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="position() &lt; last()"><xsl:text>| </xsl:text></xsl:if>
    -->
    <xsl:text>X</xsl:text>
    <xsl:if test="position() &lt; last()"><xsl:text>| </xsl:text></xsl:if>
  </xsl:for-each>
</xsl:variable>


<xsl:text>
\begin{xltabular}[c]{\linewidth}{</xsl:text>
<xsl:value-of select="$col-spec"/>
<xsl:text>}
</xsl:text>
  <xsl:apply-templates select="descendant-or-self::html:*[@id][1]/@id" mode="label"/>
<!--<xsl:for-each select="descendant-or-self::html:*[@id]">
  <xsl:apply-templates select="@id" mode="label"/>
</xsl:for-each>-->
<xsl:apply-templates select="html:thead">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
<xsl:apply-templates select="html:tbody|html:tr">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
<xsl:apply-templates select="html:tfoot">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
<xsl:text>\end{xltabular}

</xsl:text>
</xsl:template>

<xsl:template match="html:thead">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

<xsl:apply-templates select="*">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
<xsl:text>\hline
</xsl:text>
</xsl:template>

<xsl:template match="html:tfoot">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

<xsl:text>\hline
</xsl:text>
<xsl:apply-templates select="*">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
</xsl:template>

<xsl:template match="html:tbody">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

<xsl:apply-templates select="*">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
</xsl:template>

<!--
     Okay, colspan and rowspan:

     What we need on each row are enough ampersand characters (&) for
     the total number of columns (or rather N-1 colums) irrespective
     of how many row-spanning cells there are. (LaTeX complains unless
     every row has the full number of cells, over which \multirow and
     \multicolumn cells are overlaid.) Each cell on each row also
     necessarily has to determine its position, as row-spanning cells
     from previous rows may be interspersed between any two cells on a
     given row.

     The question we need to answer is: "given the current cell (tr or
     td), how many cells are occupied between it and the one preceding
     it?" The answer is A + sum(B + C) where A is the minimal offset
     of the current cell (ie the cell is at least A cells over), B (<=
     A) is the minimal offset of any cell that spans into the current
     row, and C (<= B) is the minimal offset of any row-spanning cell
     that spans *into the row-spanning cell's* first row. This problem
     initially looks recursive, but the "recursion" only has to happen
     once, because if a cell from a previous row spanned into the
     first row of a row-spanning cell, it either *also* spans into the
     first row of the original cell under inspection (in which case it
     would already be counted), or it doesn't.

     (Note also that a given cell always starts on a given row and is
     not pushed down by any prior row-spanning cells. This makes it a
     hell of a lot easier to count.)

     You know what? This whole thing is probably doable in a single
     (awful) XPath expression. Or at least built up out of a few
     expressions without having to do any boilerplate recursive
     template calls (yet).

     offset A is sum(cell[@colspan > 1]/@colspan) +
       count(cell[not(@colspan > 1)])

     Note that the formulation not(@colspan > 1) is deliberate, as
     this will also account for a missing or malformed @colspan
     attribute, whereas @colspan = 1 or @colspan < 2 will not.

-->

<xsl:template match="html:tr/html:th|html:tr/html:td">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="prev-offset" select="0"/>

  <xsl:variable name="row-offset" select="count(../preceding-sibling::html:tr)"/>
  <xsl:variable name="min-col-offset" select="count(preceding-sibling::*[not(@colspan &gt; 1)]) + sum(preceding-sibling::*[@colspan &gt; 1]/@colspan)"/>
  <xsl:variable name="width" select="count(self::*[not(@colspan &gt; 1)]) + sum(self::*[@colspan &gt; 1]/@colspan)"/>

  <xsl:variable name="rowspans-raw" select="../preceding-sibling::html:tr/html:*[@rowspan &gt; $row-offset - count(../preceding-sibling::html:tr)]"/>

  <xsl:apply-templates select="(following-sibling::html:th|following-sibling::html:td)[1]">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="html:tr">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:variable name="nth" select="count(preceding-sibling::html:tr)"/>
  <xsl:variable name="rowspans-in-scope" select="preceding-sibling::html:tr/html:*[@rowspan - 1 &gt; ($nth - count(../preceding-sibling::html:tr))]"/>

  <xsl:message>rowspans: <xsl:value-of select="count($rowspans-in-scope)"/></xsl:message>

  <xsl:for-each select="html:th|html:td">

    <xsl:choose>
      <xsl:when test="@colspan &gt; 1">
        <xsl:text>\multicolumn{</xsl:text>
        <xsl:value-of select="number(@colspan)"/>
        <xsl:text>}{l}{</xsl:text>
        <xsl:choose>
          <xsl:when test="@rowspan &gt; 1">
            <xsl:text>\multirow{</xsl:text>
            <xsl:message>wat <xsl:value-of select="@rowspan"/></xsl:message>
            <xsl:value-of select="number(@rowspan)"/>
            <xsl:text>}{*}{</xsl:text>
            <xsl:apply-templates>
              <xsl:with-param name="base" select="$base"/>
              <xsl:with-param name="resource-path" select="$resource-path"/>
              <xsl:with-param name="rewrite"       select="$rewrite"/>
              <xsl:with-param name="main"          select="$main"/>
              <xsl:with-param name="heading"       select="$heading"/>
            </xsl:apply-templates>
            <xsl:text>} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates>
              <xsl:with-param name="base" select="$base"/>
              <xsl:with-param name="resource-path" select="$resource-path"/>
              <xsl:with-param name="rewrite"       select="$rewrite"/>
              <xsl:with-param name="main"          select="$main"/>
              <xsl:with-param name="heading"       select="$heading"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@rowspan &gt; 1">
        <xsl:text>\multirow{</xsl:text>
        <xsl:value-of select="number(@rowspan)"/>
        <xsl:text>}{*}{</xsl:text>
        <xsl:apply-templates>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="resource-path" select="$resource-path"/>
          <xsl:with-param name="rewrite"       select="$rewrite"/>
          <xsl:with-param name="main"          select="$main"/>
          <xsl:with-param name="heading"       select="$heading"/>
        </xsl:apply-templates>
        <xsl:text>} </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="resource-path" select="$resource-path"/>
          <xsl:with-param name="rewrite"       select="$rewrite"/>
          <xsl:with-param name="main"          select="$main"/>
          <xsl:with-param name="heading"       select="$heading"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="position() != last()"><xsl:text> &amp; </xsl:text></xsl:if>
  </xsl:for-each>
<xsl:text> \\&#xa;</xsl:text>
</xsl:template>

<xsl:template match="html:br">
<xsl:text>\\&#x0a;</xsl:text>
</xsl:template>

<xsl:template match="html:hr">
<xsl:text>\hrulefill&#x0a;&#x0a;</xsl:text>
</xsl:template>

<!--
<xsl:template match="html:a[html:dfn|html:abbr][starts-with(normalize-space(@href), '#')]" priority="2">
<xsl:variable name="identifier" select="substring-after(normalize-space(@href), '#')"/>
<xsl:text>\hyperref[</xsl:text>
<xsl:value-of select="$identifier"/>
<xsl:text>]{</xsl:text>
<xsl:apply-templates/>
<xsl:text>}</xsl:text>
</xsl:template>-->

<xsl:template match="html:*" mode="get-nearest-id">
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="id"      select="''"/>

  <xsl:variable name="base">
    <xsl:apply-templates select="." mode="xc:get-base"/>
  </xsl:variable>

  <xsl:if test="$DEBUG">
    <xsl:message>fetching id <xsl:value-of select="$id"/> from <xsl:value-of select="$base"/></xsl:message>
  </xsl:if>

  <xsl:variable name="_">
    <xsl:choose>
      <xsl:when test="contains(normalize-space($id), '#')">
        <xsl:value-of select="normalize-space(substring-after($id, '#'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($id)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="id-element" select="key('id', $_)[1]"/>
  <!--<xsl:variable name="nearest" select="$id-element/ancestor-or-self::html:*[self::html:table|self::html:figure|self::html:section|self::html:article|self::html:main|self::html:body][1]"/>-->
  <xsl:variable name="nearest" select="($id-element/ancestor-or-self::html:body[1]|$id-element/ancestor-or-self::html:main[1]|$id-element/ancestor-or-self::html:article[1]|$id-element/ancestor-or-self::html:section[1]|$id-element/ancestor-or-self::html:figure[1]|$id-element/ancestor-or-self::html:table[1])[last()]"/>

  <xsl:message><xsl:value-of select="name($id-element)"/> -&gt; <xsl:value-of select="name($nearest)"/></xsl:message>

  <xsl:choose>
    <xsl:when test="$nearest[@id]">
      <!-- this may in fact be the one we were given -->
      <xsl:value-of select="normalize-space($nearest/@id)"/>
    </xsl:when>
    <xsl:otherwise>
      <!-- otherwise we get the id of the first descendant that has one -->
      <xsl:value-of select="normalize-space($nearest/descendant::html:*[@id][1]/@id)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="html:*" mode="get-ref-text">
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="id"      select="''"/>

  <xsl:variable name="base">
    <xsl:apply-templates select="." mode="xc:get-base"/>
  </xsl:variable>

  <xsl:variable name="_">
    <xsl:choose>
      <xsl:when test="contains(normalize-space($id), '#')">
        <xsl:value-of select="normalize-space(substring-after($id, '#'))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($id)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="node" select="key('id', $_)[1]"/>

  <xsl:choose>
    <xsl:when test="$node/ancestor-or-self::html:table">
      <xsl:text>Table </xsl:text>
    </xsl:when>
    <xsl:when test="$node/ancestor-or-self::html:figure">
      <xsl:text>Fig. </xsl:text>
    </xsl:when>
    <xsl:otherwise><xsl:text>\S .</xsl:text></xsl:otherwise>
  </xsl:choose>
</xsl:template>
  
<xsl:template match="html:a[@href]">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:variable name="origin">
    <xsl:call-template name="xc:get-origin">
      <xsl:with-param name="resource-path" select="$resource-path"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="href-raw">
    <xsl:call-template name="uri:resolve-uri">
      <xsl:with-param name="uri" select="@href"/>
      <xsl:with-param name="base" select="$base"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="href">
    <xsl:apply-templates select="@href" mode="xc:href">
      <xsl:with-param name="base"          select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite"       select="$rewrite"/>
    </xsl:apply-templates>
  </xsl:variable>

  <xsl:if test="$DEBUG">
    <xsl:message>parent: <xsl:value-of select="name(..)"/>, base: <xsl:value-of select="$base"/>, href: <xsl:value-of select="$href-raw"/> -&gt; <xsl:value-of select="$href"/></xsl:message>
  </xsl:if>

  <xsl:variable name="fragment">
    <xsl:variable name="_" select="substring-after($href, $origin)"/>
    <xsl:if test="starts-with($href, $origin) and starts-with($_, '#')">
      <xsl:value-of select="$_"/>
    </xsl:if>
  </xsl:variable>
<xsl:choose>
  <xsl:when test="starts-with($fragment, '#')">
    <!--
        \label doesn't work more granularly than sections/figures/tables.
        we need to be able to get the id 
        
    -->

    <xsl:variable name="doc">
      <xsl:choose>
          <xsl:when test="contains($href-raw, '#')">
            <xsl:value-of select="substring-before($href-raw, '#')"/>
          </xsl:when>
          <xsl:otherwise><xsl:value-of select="$href-raw"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="doc-root" select="document($doc)/*"/>

    <xsl:variable name="identifier">
      <!--<xsl:message><xsl:value-of select="$href"/>: <xsl:value-of select="count(document(substring-before($href, '#')))"/></xsl:message>-->
      <xsl:apply-templates select="$doc-root" mode="get-nearest-id">
        <xsl:with-param name="resource-path" select="$resource-path"/>
        <xsl:with-param name="rewrite"       select="$rewrite"/>
        <xsl:with-param name="main"          select="$main"/>
        <xsl:with-param name="heading"       select="$heading"/>
        <xsl:with-param name="id"            select="substring-after($fragment, '#')"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="_">
      <xsl:text>\footnote{\hyperref[</xsl:text>
      <xsl:value-of select="$identifier"/>
      <xsl:text>]{</xsl:text>

      <xsl:apply-templates select="$doc-root" mode="get-ref-text">
        <xsl:with-param name="resource-path" select="$resource-path"/>
        <xsl:with-param name="rewrite"       select="$rewrite"/>
        <xsl:with-param name="main"          select="$main"/>
        <xsl:with-param name="heading"       select="$heading"/>
        <xsl:with-param name="id"            select="substring-after($fragment, '#')"/>
      </xsl:apply-templates>

      <xsl:text> \ref*{</xsl:text>
      <xsl:value-of select="$identifier"/>
      <xsl:text>}, p.\pageref{</xsl:text>
      <xsl:value-of select="$identifier"/>
      <xsl:text>}}}</xsl:text>
      <!--
      <xsl:text>\hyperref[</xsl:text>
      <xsl:value-of select="$identifier"/><xsl:text>]{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>-->
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="ancestor::html:dt">
        <!--<xsl:value-of select="concat('\protect{', $_, '}')"/>-->
        <xsl:apply-templates>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="resource-path" select="$resource-path"/>
          <xsl:with-param name="rewrite"       select="$rewrite"/>
          <xsl:with-param name="main"          select="$main"/>
          <xsl:with-param name="heading"       select="$heading"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates>
          <xsl:with-param name="base" select="$base"/>
          <xsl:with-param name="resource-path" select="$resource-path"/>
          <xsl:with-param name="rewrite"       select="$rewrite"/>
          <xsl:with-param name="main"          select="$main"/>
          <xsl:with-param name="heading"       select="$heading"/>
        </xsl:apply-templates>
        <xsl:value-of select="$_"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:when test="contains($href, '://')">
    <xsl:apply-templates>
      <xsl:with-param name="base" select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite"       select="$rewrite"/>
      <xsl:with-param name="main"          select="$main"/>
      <xsl:with-param name="heading"       select="$heading"/>
    </xsl:apply-templates>
    <xsl:text>\footnote{\protect\url{</xsl:text>
    <!--<xsl:text>\footnote{\url{</xsl:text>-->
    <xsl:call-template name="process-text">
      <xsl:with-param name="text" select="$href"/>
      <xsl:with-param name="is-uri" select="true()"/>
    </xsl:call-template>
    <xsl:text>}}</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\href{</xsl:text><xsl:value-of select="$href"/>
    <xsl:text>}{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
  </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="html:a[@href][ancestor::html:h1|ancestor::html:h2|ancestor::html:h3|ancestor::html:h4|ancestor::html:h5|ancestor::html:h6]" priority="2">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <!-- this should be a noop as it screws with the table of contents -->
  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>

</xsl:template>

<xsl:template match="html:blockquote[contains(@class, 'note')]|html:aside[contains(@role, 'note')]">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
<!--<xsl:text>\marginnote{</xsl:text><xsl:apply-templates/><xsl:text>}
</xsl:text>-->
<xsl:text>
\begin{marginfigure}
\footnotesize
</xsl:text>
<xsl:apply-templates>
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
<xsl:text>
\end{marginfigure}

</xsl:text>
</xsl:template>

<xsl:template match="html:blockquote">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
<xsl:text>
\begin{quotation}
</xsl:text>
<xsl:apply-templates select="*">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>

<xsl:text>
\end{quotation}

</xsl:text>
</xsl:template>

<xsl:template match="html:cite">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
<xsl:text>\hfill ---</xsl:text><xsl:apply-templates>
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
</xsl:template>

<xsl:template match="html:figure[@role='note']"/>

<!-- special one for table -->
<xsl:template match="html:figure[html:table][count(*) = 1]|html:figure[html:table[following-sibling::html:figcaption]][count(*) = 2]">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:apply-templates select="html:table">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="html:figure">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

<xsl:text>
\begin{figure}[ht]
\centering
</xsl:text>
<xsl:apply-templates select="*">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
<xsl:text>
\end{figure}

</xsl:text>
</xsl:template>

<xsl:template match="html:figcaption">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

<xsl:variable name="content">
<xsl:apply-templates select="*">
  <xsl:with-param name="base" select="$base"/>
  <xsl:with-param name="resource-path" select="$resource-path"/>
  <xsl:with-param name="rewrite"       select="$rewrite"/>
  <xsl:with-param name="main"          select="$main"/>
  <xsl:with-param name="heading"       select="$heading"/>
</xsl:apply-templates>
</xsl:variable>
<xsl:choose>
  <xsl:when test="contains($content, '&#xa;') and string-length(normalize-space(substring-after($content, '&#xa;'))) != 0">
    <xsl:variable name="first-para" select="normalize-space(substring-before($content, '&#xa;'))"/>
    <xsl:value-of select="concat('\caption[', $first-para, ']{')"/>
  </xsl:when>
  <xsl:otherwise><xsl:text>\caption{</xsl:text></xsl:otherwise>
</xsl:choose>
<xsl:value-of select="concat('\footnotesize{}', normalize-space($content))"/>
<xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template match="html:figure/html:img|html:figure/html:object[@type='image/svg+xml']">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:variable name="src" select="(@data|@src)[1]"/>
<xsl:text>\includegraphics[width=0.9\textwidth]{</xsl:text>
<xsl:choose>
  <xsl:when test="starts-with($src, '/') and not(contains($src, '.'))">
    <xsl:value-of select="concat(substring-after($src, '/'), '.pdf')"/>
  </xsl:when>
  <xsl:when test="@type = 'image/svg+xml'">
    <!--<xsl:value-of select="concat(substring-after($src, '/'), '.svg')"/>-->
    <xsl:value-of select="concat($src, '.svg')"/>
  </xsl:when>
<xsl:otherwise><xsl:value-of select="$src"/></xsl:otherwise>
</xsl:choose>
<xsl:text>}</xsl:text>
</xsl:template>

<!-- XXX not sure why this gets overridden but we need to copy it here -->

<xsl:template match="html:script[@src][contains(translate(@type, 'XML', 'xml'), 'xml')]">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite"       select="''"/>
  <xsl:param name="main"          select="false()"/>
  <xsl:param name="heading"       select="0"/>
  <xsl:param name="debug"         select="$xc:DEBUG"/>

  <xsl:variable name="src">
    <xsl:call-template name="uri:resolve-uri">
      <xsl:with-param name="uri" select="@src"/>
      <xsl:with-param name="base" select="$base"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test="$debug">
    <xsl:message>script tag rewrites: <xsl:value-of select="$rewrite"/></xsl:message>
  </xsl:if>

  <xsl:apply-templates select="." mode="xc:transclude-element">
    <xsl:with-param name="base"          select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
    <xsl:with-param name="src"           select="$src"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="html:section|html:article|html:main|html:body" mode="xc:transclude-shim">
  <xsl:param name="base"/>
  <xsl:param name="resource-path"/>
  <xsl:param name="rewrite"/>
  <xsl:param name="main"/>
  <xsl:param name="heading"/>
  <xsl:param name="uri"/>
  <xsl:param name="caller"/>
  <xsl:param name="merged" select="false()"/>

  <xsl:variable name="h-elem" select="(html:h1|html:h2|html:h3|html:h4|html:h5|html:h6|ancestor::html:html[1]/html:head[1]/html:title[1])[1]"/>
  <xsl:apply-templates select="$h-elem" mode="xc:heading">
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>

  <xsl:apply-templates select="@id" mode="label"/>

  <xsl:apply-templates>
    <xsl:with-param name="base" select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading + 1"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="html:*" mode="xc:transclude-shim">
  <xsl:param name="base"/>
  <xsl:param name="resource-path"/>
  <xsl:param name="rewrite"/>
  <xsl:param name="main"/>
  <xsl:param name="heading"/>
  <xsl:param name="uri"/>
  <xsl:param name="caller"/>
  <xsl:param name="merged" select="false()"/>

  <xsl:variable name="parent" select="$caller/parent::*"/>

  <xsl:apply-templates select="." mode="xc:maybe-wrap">
    <xsl:with-param name="base"          select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
    <xsl:with-param name="uri"           select="$uri"/>
    <xsl:with-param name="caller"        select="$caller"/>
    <xsl:with-param name="merged"        select="$merged"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="html:*" mode="xc:wrap">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite"       select="''"/>
  <xsl:param name="main"          select="false()"/>
  <xsl:param name="heading"       select="0"/>

  <xsl:apply-templates select="*|text()">
    <xsl:with-param name="base"          select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="html:article|html:section" mode="xc:merge">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>
  <xsl:param name="debug"   select="$xc:DEBUG"/>
  <xsl:param name="target">
    <xsl:message>$target is a mandatory parameter</xsl:message>
  </xsl:param>
  <xsl:param name="caller">
    <xsl:message>$caller is a mandatory parameter</xsl:message>
  </xsl:param>
  <xsl:param name="uri">
    <xsl:message>$uri is a mandatory parameter</xsl:message>
  </xsl:param>
  <xsl:param name="plain" select="false()"/>

  <xsl:apply-templates select="$target" mode="xc:transclude-shim">
    <xsl:with-param name="base"          select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
    <xsl:with-param name="uri"           select="$uri"/>
    <xsl:with-param name="caller"        select="$caller"/>
  </xsl:apply-templates>

</xsl:template>

<xsl:template match="html:*" priority="-1">
  <xsl:param name="base">
    <xsl:apply-templates select="." mode="xc:assert-base"/>
  </xsl:param>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite"       select="''"/>
  <xsl:param name="main"          select="false()"/>
  <xsl:param name="heading"       select="0"/>
  <xsl:param name="debug"         select="$xc:DEBUG"/>

  <xsl:if test="$debug">
    <xsl:message>MY catch-all running on node: <xsl:value-of select="name()"/>; base: <xsl:value-of select="$base"/></xsl:message>
  </xsl:if>

  <xsl:apply-templates>
    <xsl:with-param name="base"          select="$base"/>
    <xsl:with-param name="resource-path" select="$resource-path"/>
    <xsl:with-param name="rewrite"       select="$rewrite"/>
    <xsl:with-param name="main"          select="$main"/>
    <xsl:with-param name="heading"       select="$heading"/>
  </xsl:apply-templates>

</xsl:template>

</xsl:stylesheet>
