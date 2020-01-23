<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:html="http://www.w3.org/1999/xhtml"
                xmlns:z="urn:x-dummy:data"
                exclude-result-prefixes="z">
  

<xsl:output method="text" media-type="text/x-tex" encoding="utf-8"/>

<xsl:key name="main" match="html:main[not(@hidden)]" use="''"/>
<xsl:key name="article" match="html:article" use="''"/>
<xsl:key name="section" match="html:section" use="''"/>

<!--
<xsl:template match="text()">
<xsl:value-of select="normalize-space(translate(., '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', ''))"/>
</xsl:template>-->

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

<xsl:template match="text()" name="process-text">
  <xsl:param name="text" select="."/>
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
        <xsl:with-param name="depth" select="$depth + 1"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:value-of select="$char/@replace"/>

    <xsl:if test="string-length($after) != 0">
      <!--<xsl:message>AFTER <xsl:value-of select="$depth"/>: <xsl:value-of select="$after"/></xsl:message>-->
      <xsl:call-template name="process-text">
        <xsl:with-param name="text" select="$after"/>
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

<xsl:apply-templates select="html:meta"/>
<xsl:apply-templates select="html:title"/>

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

<xsl:template match="/">
<!-- this thing is mocking me today -->
<!--<xsl:variable name="is-contract" select="contains(concat(' ', normalize-space(/html:html/html:body/@typeof), ' '), ' bibo:LegalDocument ')"/>-->
<xsl:variable name="is-contract" select="true()"/>

<xsl:variable name="has-main" select="key('main', '')[1]"/>
<xsl:variable name="has-article" select="key('article', '')[1]"/>
<xsl:variable name="has-section" select="key('section', '')[1]"/>

<xsl:variable name="document-class">
  <xsl:choose>
    <xsl:when test="$is-contract"><xsl:value-of select="'article'"/></xsl:when>
    <xsl:when test="not($has-section)"><xsl:value-of select="'article'"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="'report'"/></xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<xsl:text>\documentclass[letterpaper,twoside,10pt]{</xsl:text>
<xsl:value-of select="$document-class"/><xsl:text>}
\usepackage[utf8]{inputenc}
\usepackage{palatino}
\usepackage[bookmarks=true,unicode=true,colorlinks=false,hidelinks=true]{hyperref}
\usepackage[T1]{fontenc}
\usepackage{textcomp}
\usepackage{gensymb}
\usepackage{marginnote}
\usepackage{sidenotes}
\usepackage{graphicx}
\usepackage{enumitem}
\renewcommand{\abstractname}{Executive Summary}
</xsl:text>

<xsl:apply-templates select="html:html/html:head"/>


<xsl:text>
\setlength{\parskip}{1em}
\setlength{\parindent}{0em}
\begin{document}
\maketitle
</xsl:text>

<xsl:if test="$has-section and not($is-contract)">
<xsl:text>
\begin{abstract}
</xsl:text>

<xsl:apply-templates select="html:html/html:body/html:p"/>

<xsl:text>
\end{abstract}

</xsl:text>
</xsl:if>

<xsl:if test="$has-section and not($is-contract)">
<xsl:text>
\tableofcontents

</xsl:text>
</xsl:if>

<xsl:if test="$is-contract">
</xsl:if>

<!--<xsl:apply-templates select="html:html/html:body/html:article[2]/html:section"/>-->
<xsl:apply-templates select="($has-article|$has-main|html:html/html:body)[1]"/>

<!--<xsl:apply-templates select="html:html/html:body/html:article[position() != 1]/html:section">
</xsl:apply-templates>-->
<xsl:text>
\end{document}</xsl:text>
</xsl:template>

<xsl:template match="html:section">
<!--<xsl:variable name="is-contract" select="contains(concat(' ', normalize-space(/html:html/html:body/@typeof), ' '), ' bibo:LegalDocument ')"/>-->
<xsl:variable name="is-contract" select="true()"/>
<xsl:variable name="sec-adj" select="number(boolean($is-contract))"/>

<xsl:text>
</xsl:text>
<xsl:choose>
  <xsl:when test="not($is-contract) and count(ancestor::html:section) = 0">
    <xsl:text>\chapter{</xsl:text>
    <xsl:apply-templates select="(html:h1|html:h2|html:h3|html:h4|html:h5|html:h6)[1]"/>
    <xsl:text>}
</xsl:text>
  </xsl:when>
  <xsl:when test="count(ancestor::html:section) &lt; (4 - $sec-adj)">
    <xsl:text>\</xsl:text>
    <xsl:choose>
      <xsl:when test="$is-contract">
        <xsl:for-each select="ancestor::html:section">
          <xsl:text>sub</xsl:text>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="ancestor::html:section[ancestor::html:section]">
          <xsl:text>sub</xsl:text>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>section{</xsl:text>
    <xsl:apply-templates select="(html:h1|html:h2|html:h3|html:h4|html:h5|html:h6)[1]"/>
    <xsl:text>}
</xsl:text>
  </xsl:when>
  <xsl:when test="count(ancestor::html:section) = (4 - $sec-adj)">
    <xsl:text>\paragraph{</xsl:text>
    <xsl:apply-templates select="(html:h1|html:h2|html:h3|html:h4|html:h5|html:h6)[1]"/>
    <xsl:text>}
</xsl:text>
  </xsl:when>
  <xsl:when test="count(ancestor::html:section) = (5 - $sec-adj)">
    <xsl:text>\subparagraph</xsl:text>
  </xsl:when>
</xsl:choose>
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:apply-templates select="*[not(self::html:h1|self::html:h2|self::html:h3|self::html:h4|self::html:h5|self::html:h6)]"/>
</xsl:template>

<xsl:template match="html:dl[parent::html:section][not(following-sibling::*)][not(preceding-sibling::*) or preceding-sibling::html:h1|preceding-sibling::html:h2|preceding-sibling::html:h3|preceding-sibling::html:h4|preceding-sibling::html:h5|preceding-sibling::html:h6]" priority="2">
  <xsl:for-each select="html:dt">
    <xsl:text>\paragraph{</xsl:text>
    <xsl:apply-templates select="node()"/>
    <xsl:text>}
</xsl:text>
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:variable name="dt-id" select="generate-id(.)"/>
<xsl:for-each select="following-sibling::html:dd[generate-id(preceding-sibling::html:dt[1]) = $dt-id]">
<xsl:apply-templates select="node()"/>
<xsl:text>

</xsl:text>
</xsl:for-each>
</xsl:for-each>
</xsl:template>

<xsl:template match="html:p">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:apply-templates/>
<xsl:text>

</xsl:text>
</xsl:template>

<xsl:template match="html:q">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>``</xsl:text><xsl:apply-templates/><xsl:text>''</xsl:text>
</xsl:template>

<xsl:template match="html:samp">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>\texttt{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
</xsl:template>

<!-- XXX make this go to refs or something -->
<xsl:template match="html:dfn|html:abbr">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>\textsc{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
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
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>\textbf{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="html:em">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>\emph{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="html:code|html:samp|html:kbd">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>\texttt{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="html:var">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>$</xsl:text><xsl:apply-templates/><xsl:text>$</xsl:text>
</xsl:template>

<xsl:template match="html:ul">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>
\begin{itemize}
</xsl:text>
<xsl:apply-templates select="html:li"/>
<xsl:text>\end{itemize}

</xsl:text>
</xsl:template>

<xsl:template match="html:ol">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>
\begin{enumerate}
</xsl:text>
<xsl:apply-templates select="html:li"/>
<xsl:text>\end{enumerate}

</xsl:text>
</xsl:template>

<xsl:template match="html:li">
<xsl:text>\item </xsl:text><xsl:apply-templates/><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="html:dl">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
<xsl:text>
\begin{description}[style=nextline]
</xsl:text>
<xsl:apply-templates select="html:dt|html:dd"/>
<xsl:text>\end{description}

</xsl:text>
</xsl:template>

<xsl:template match="html:dt">
<xsl:text>\item [</xsl:text>
<xsl:apply-templates/><xsl:text>] </xsl:text>
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>
</xsl:template>

<xsl:template match="html:dd">
<xsl:apply-templates/>
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="html:table">
<xsl:if test="@id">
<xsl:text>\label{</xsl:text><xsl:value-of select="@id"/><xsl:text>}
</xsl:text>
</xsl:if>

<xsl:variable name="max-cols">
  <xsl:for-each select="html:tr|html:thead/html:tr|html:tbody/html:tr|html:tfoot/html:tr">
    <xsl:sort select="count(html:th|html:td)" data-type="number" order="descending"/>
    <xsl:if test="position() = 1"><xsl:value-of select="count(html:th|html:td)"/></xsl:if>
  </xsl:for-each>
</xsl:variable>

<xsl:variable name="col-spec">
  <xsl:variable name="_" select="(html:tbody/html:tr|html:tr)[count(*) = number($max-cols)][1]"/>
  <xsl:for-each select="$_/html:th|$_/html:td">
    <xsl:choose>
      <xsl:when test="local-name() = 'th'">
        <xsl:text>p{</xsl:text>
        <xsl:value-of select="round(1 div number($max-cols) * 80) div 100"/>
        <xsl:text>\textwidth}</xsl:text>
        <xsl:if test="position() &lt; last()"><xsl:text>| </xsl:text></xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>p{</xsl:text>
        <xsl:value-of select="round(1 div number($max-cols) * 80) div 100"/>
        <xsl:text>\textwidth}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:for-each>
</xsl:variable>


<xsl:text>
\begin{tabular}{</xsl:text>
<xsl:value-of select="$col-spec"/>
<xsl:text>}
</xsl:text>
<xsl:apply-templates select="html:thead"/>
<xsl:apply-templates select="html:tbody|html:tr"/>
<xsl:apply-templates select="html:tfoot"/>
<xsl:text>\end{tabular}

</xsl:text>
</xsl:template>

<xsl:template match="html:thead">
<xsl:apply-templates select="*"/>
<xsl:text>\hline
</xsl:text>
</xsl:template>

<xsl:template match="html:tfoot">
<xsl:text>\hline
</xsl:text>
<xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="html:tbody">
<xsl:apply-templates select="*"/>
</xsl:template>


<xsl:template match="html:tr">
  <xsl:for-each select="html:th|html:td">
    <xsl:apply-templates/>
    <xsl:if test="position() != last()"><xsl:text> &amp; </xsl:text></xsl:if>
  </xsl:for-each>
<xsl:text> \\
</xsl:text>
</xsl:template>

<xsl:template match="html:br">
<xsl:text>\\
</xsl:text>
</xsl:template>

<xsl:template match="html:hr">
<xsl:text>\hrulefill
</xsl:text>
</xsl:template>

<xsl:template match="html:a[html:dfn|html:abbr][starts-with(normalize-space(@href), '#')]" priority="2">
<xsl:variable name="identifier" select="substring-after(normalize-space(@href), '#')"/>
<xsl:text>\hyperref[</xsl:text>
<xsl:value-of select="$identifier"/>
<xsl:text>]{</xsl:text>
<xsl:apply-templates/>
<xsl:text>}</xsl:text>
</xsl:template>

<xsl:template match="@href" mode="href-text">
<xsl:value-of select="."/>
</xsl:template>

<xsl:template match="html:a[@href]">
  <xsl:param name="base" select="normalize-space((ancestor-or-self::html:html[html:head/html:base[@href]][1]/html:head/html:base[@href])[1]/@href)"/>
  <xsl:param name="resource-path" select="$base"/>
  <xsl:param name="rewrite" select="''"/>
  <xsl:param name="main"    select="false()"/>
  <xsl:param name="heading" select="0"/>

  <xsl:variable name="href">
    <xsl:apply-templates select="@href" mode="href-text">
      <xsl:with-param name="base"          select="$base"/>
      <xsl:with-param name="resource-path" select="$resource-path"/>
      <xsl:with-param name="rewrite"       select="$rewrite"/>
    </xsl:apply-templates>
  </xsl:variable>
<xsl:choose>
  <xsl:when test="starts-with($href, '#')">
    <xsl:variable name="identifier" select="substring-after($href, '#')"/>
    <xsl:variable name="_">
      <xsl:text>\footnote{\hyperref[</xsl:text>
      <xsl:value-of select="$identifier"/>
      <xsl:text>]{\S .\ref*{</xsl:text>
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
        <xsl:apply-templates/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
        <xsl:value-of select="$_"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:when test="contains($href, '://')">
    <xsl:apply-templates/>
    <xsl:text>\footnote{\protect\url{</xsl:text>
    <xsl:call-template name="process-text">
      <xsl:with-param name="text" select="$href"/>
    </xsl:call-template>
    <xsl:text>}}</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:text>\href{</xsl:text><xsl:value-of select="$href"/>
    <xsl:text>}{</xsl:text><xsl:apply-templates/><xsl:text>}</xsl:text>
  </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="html:blockquote[contains(@class, 'note')]|html:aside[contains(@role, 'note')]">
<!--<xsl:text>\marginnote{</xsl:text><xsl:apply-templates/><xsl:text>}
</xsl:text>-->
<xsl:text>
\begin{marginfigure}
\footnotesize
</xsl:text>
<xsl:apply-templates>
</xsl:apply-templates>
<xsl:text>
\end{marginfigure}

</xsl:text>
</xsl:template>

<xsl:template match="html:blockquote">
<xsl:text>
\begin{quotation}
</xsl:text>
<xsl:apply-templates select="*">
</xsl:apply-templates>
<xsl:text>
\end{quotation}

</xsl:text>
</xsl:template>

<xsl:template match="html:cite">
<xsl:text>\hfill ---</xsl:text><xsl:apply-templates>
</xsl:apply-templates>
</xsl:template>

<xsl:template match="html:figure[@role='note']"/>

<xsl:template match="html:figure">
<xsl:text>
\begin{figure}[ht]
\centering
</xsl:text>
<xsl:apply-templates select="*">
</xsl:apply-templates>
<xsl:text>
\end{figure}

</xsl:text>
</xsl:template>

<xsl:template match="html:figcaption">
<xsl:variable name="content">
<xsl:apply-templates select="*">
</xsl:apply-templates>
</xsl:variable>
<xsl:choose>
  <xsl:when test="contains($content, '&#xa;') and string-length(normalize-space(substring-after($content, '&#xa;'))) != 0">
    <xsl:variable name="first-para" select="normalize-space(substring-before($content, '&#xa;'))"/>
    <xsl:value-of select="concat('\caption[', $first-para, ']{')"/>
  </xsl:when>
  <xsl:otherwise><xsl:text>\caption{</xsl:text></xsl:otherwise>
</xsl:choose>
<xsl:value-of select="concat('\footnotesize{}', $content)"/>
<xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template match="html:figure/html:img|html:figure/html:object[@type='image/svg+xml']">
  <xsl:variable name="src" select="(@data|@src)[1]"/>
<xsl:text>\includegraphics[width=0.9\textwidth]{</xsl:text>
<xsl:choose>
  <xsl:when test="starts-with($src, '/') and not(contains($src, '.'))">
    <xsl:value-of select="concat(substring-after($src, '/'), '.pdf')"/>
  </xsl:when>
  <xsl:when test="@type = 'image/svg+xml'">
    <xsl:value-of select="concat(substring-after($src, '/'), '.svg')"/>
  </xsl:when>
<xsl:otherwise><xsl:value-of select="$src"/></xsl:otherwise>
</xsl:choose>
<xsl:text>}</xsl:text>
</xsl:template>

</xsl:stylesheet>
