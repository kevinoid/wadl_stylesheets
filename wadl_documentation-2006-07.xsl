<?xml version="1.0" encoding="UTF-8"?>
<!--
  wadl_documentation.xsl (2006-09-01)

  An XSLT stylesheet for generating HTML documentation from WADL,
  by Mark Nottingham <mnot@yahoo-inc.com>.

  Copyright (c) 2006 Yahoo! Inc.
  
  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 
  License. To view a copy of this license, visit 
    http://creativecommons.org/licenses/by-sa/2.5/ 
  or send a letter to 
    Creative Commons
    543 Howard Street, 5th Floor
    San Francisco, California, 94105, USA
-->
<!--
  * TODO
    - param/link
    - link to or include non-schema variable type defs (as a separate list?)
    - @href error handling
    - XML schema import, include, redefine
 -->

<xsl:stylesheet 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.1"
 xmlns:wadl="http://research.sun.com/wadl/2006/07"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:html="http://www.w3.org/1999/xhtml"
 xmlns="http://www.w3.org/1999/xhtml"
 exclude-result-prefixes="xsl wadl xs html"
>

    <xsl:output 
        method="xml"
        omit-xml-declaration="yes"
        encoding="UTF-8" 
        indent="yes"
        media-type="application/xhtml+xml"
        doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    />

    <xsl:variable name="wadl-ns">http://research.sun.com/wadl/2006/07</xsl:variable>

    <!-- collect grammars -->
    
    <xsl:variable name="grammars">
        <xsl:copy-of select="/wadl:application/wadl:grammars/*[not(namespace-uri()=$wadl-ns)]"/>
        <xsl:apply-templates select="/wadl:application/wadl:grammars/wadl:include[@href]" mode="include-grammar"/>
        <xsl:apply-templates select="/wadl:application/wadl:resources/descendant::wadl:*[@href]" mode="include-href"/>
    </xsl:variable>
    
    <xsl:template match="wadl:include[@href]" mode="include-grammar">
        <xsl:variable name="included" select="document(@href, /)/*"></xsl:variable>
        <xsl:element name="wadl:include">
            <xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
            <xsl:copy-of select="$included"/> <!-- xml-schema -->
        </xsl:element>
    </xsl:template>

    <xsl:template match="wadl:*[@href]" mode="include-href">
            <xsl:variable name="uri" select="substring-before(@href, '#')"/>
            <xsl:if test="$uri">
                <xsl:variable name="included" select="document($uri, /)"/>
                <xsl:copy-of select="$included/wadl:application/wadl:grammars/*[not(namespace-uri()=$wadl-ns)]"/>
                <xsl:apply-templates select="$included/descendant::wadl:include[@href]" mode="include-grammar"/>
                <xsl:apply-templates select="$included/wadl:application/wadl:resources/descendant::wadl:*[@href]" mode="include-href"/>
            </xsl:if>
        </xsl:template>

    <!-- expand @hrefs into a full tree -->

    <xsl:variable name="resources">
        <xsl:apply-templates select="/wadl:application/wadl:resources" mode="expand-href"/>
    </xsl:variable>

    <xsl:template match="wadl:*[@href]" mode="expand-href">
        <xsl:variable name="uri" select="substring-before(@href, '#')"/>
        <xsl:variable name="id" select="substring-after(@href, '#')"/>
        <xsl:choose>
            <xsl:when test="$uri">
                <xsl:variable name="included" select="document($uri, /)"/>
                <xsl:apply-templates select="$included/descendant::wadl:*[@id=$id]" mode="expand-href"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//wadl:*[@id=$id]" mode="expand-href"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <xsl:template match="@*|node()" mode="expand-href">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="expand-href"/>
        </xsl:copy>
    </xsl:template>
        
    <!-- main template -->
        
    <xsl:template match="/wadl:application">        
        <html>
            <head>
                <title>
                    <xsl:choose>
                        <xsl:when test="wadl:doc[@title]">
                            <xsl:value-of select="wadl:doc[@title][1]/@title"/>
                        </xsl:when>
                        <xsl:otherwise>My Web Application</xsl:otherwise>
                    </xsl:choose>                 
                </title>
                <style type="text/css">
                    body {
                        font-family: sans-serif;
                        font-size: 0.85em;
                        margin: 2em 8em;
                    }
                    .methods {
                        background-color: #eef;
                        padding: 1em;
                    }
                    h1 {
                        font-size: 2.5em;
                    }
                    h2 {
                        border-bottom: 1px solid black;
                        margin-top: 1em;
                        margin-bottom: 0.5em;
                        font-size: 2em;
                       }
                    h3 {
                        color: orange;
                        font-size: 1.75em;
                        margin-top: 1.25em;
                        margin-bottom: 0em;
                    }
                    h4 {
                        margin: 0em;
                        padding: 0em;
                        border-bottom: 2px solid white;
                    }
                    h6 {
                        font-size: 1.1em;
                        color: #99a;
                        margin: 0.5em 0em 0.25em 0em;
                    }
                    dd {
                        margin-bottom: 0.5em;
                    }
                    code {
                        font-size: 1.2em;
                    }
                    var {
                        font-style: normal;
                        font-weight: bold;
                    }
                    table {
                        margin-bottom: 0.5em;
                    }
                    th {
                        text-align: left;
                        font-weight: normal;
                        color: black;
                        border-bottom: 1px solid black;
                        padding: 3px 6px;
                    }
                    td {
                        padding: 3px 6px;
                        vertical-align: top;
                        background-color: f6f6ff;
                        font-size: 0.85em;
                    }
                    td p {
                        margin: 0px;
                    }
                    ul {
                        padding-left: 1.75em;
                    }
                    p + ul {
                        margin-top: 0em;
                    }
                    .optional {
                        font-weight: normal;
                        opacity: 0.75;
                    }
                </style>
            </head>
            <body>
                <h1>
                    <xsl:choose>
                        <xsl:when test="wadl:doc[@title]">
                            <xsl:value-of select="wadl:doc[@title][1]/@title"/>
                        </xsl:when>
                        <xsl:otherwise>My Web Application</xsl:otherwise>
                    </xsl:choose>
                </h1>
                <xsl:apply-templates select="wadl:doc"/>                
                <ul>
                    <li><a href="#resources">Resources</a></li>
                        <xsl:apply-templates select="$resources" mode="toc"/>
                    <li><a href="#representations">Representations</a></li>
                        <ul>
                            <xsl:apply-templates select="$resources/descendant::wadl:representation" mode="toc"/>
                        </ul>
                    <xsl:if test="descendant::wadl:fault">
                        <li><a href="#faults">Faults</a></li>
                    </xsl:if>
                </ul>
                <h2 id="resources">Resources</h2>
                <xsl:apply-templates select="$resources" mode="list"/>
                <h2 id="representations">Representations</h2>
                <xsl:apply-templates select="$resources/descendant::wadl:representation" mode="list"/>
                <xsl:if test="$resources/descendant::wadl:fault"><h2 id="faults">Faults</h2>
                    <xsl:apply-templates select="$resources/descendant::wadl:fault" mode="list"/>
                </xsl:if>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="wadl:resources" mode="toc">
        <xsl:variable name="base">
            <xsl:choose>
                <xsl:when test="substring(@base, string-length(@base), 1) = '/'">
                    <xsl:value-of select="substring(@base, 1, string-length(@base) - 1)"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="@base"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <ul>
            <xsl:apply-templates select="wadl:resource" mode="toc">
                <xsl:with-param name="context"><xsl:value-of select="$base"/></xsl:with-param>
            </xsl:apply-templates>
        </ul>        
    </xsl:template>

    <xsl:template match="wadl:resources" mode="list">
        <xsl:variable name="base">
            <xsl:choose>
                <xsl:when test="substring(@base, string-length(@base), 1) = '/'">
                    <xsl:value-of select="substring(@base, 1, string-length(@base) - 1)"/>
                </xsl:when>
                <xsl:otherwise><xsl:value-of select="@base"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates select="wadl:resource" mode="list"/>
                
    </xsl:template>
    
    <xsl:template match="wadl:resource" mode="toc">
        <xsl:param name="context"/>
        <xsl:variable name="id"><xsl:call-template name="get-id"/></xsl:variable>
        <xsl:variable name="name"><xsl:value-of select="$context"/>/<xsl:value-of select="@path"/></xsl:variable>
            <li><a href="#{$id}"><xsl:value-of select="$name"/></a></li>
        <xsl:if test="wadl:resource">
            <ul>
                <xsl:apply-templates select="wadl:resource" mode="toc">
                    <xsl:with-param name="context" select="$name"/>
                </xsl:apply-templates>
            </ul>
        </xsl:if>
    </xsl:template>

    <xsl:template match="wadl:resource" mode="list">
        <xsl:param name="context"/>
        <xsl:variable name="href" select="@id"/>
        <xsl:choose>
            <xsl:when test="preceding::wadl:resource[@id=$href]"/>
            <xsl:otherwise>
                <xsl:variable name="id"><xsl:call-template name="get-id"/></xsl:variable>
                <xsl:variable name="name">
                    <xsl:value-of select="$context"/>/<xsl:value-of select="@path"/>
                    <xsl:for-each select="wadl:param[@style='matrix']">
                        <span class="optional">;<xsl:value-of select="@name"/>=...</span>
                    </xsl:for-each>
                </xsl:variable>
                <div class="resource">
                    <h3 id="{$id}">
                        <xsl:choose>
                            <xsl:when test="wadl:doc[@title]"><xsl:value-of select="wadl:doc[@title][1]/@title"/></xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="$name"/>
                                <xsl:for-each select="wadl:method[1]/wadl:request/wadl:param">
                                    <xsl:choose>
                                        <xsl:when test="@required='true'">
                                            <xsl:choose>
                                                <xsl:when test="preceding-sibling::wadl:param">&amp;</xsl:when>
                                                <xsl:otherwise>?</xsl:otherwise>
                                            </xsl:choose>
                                            <xsl:value-of select="@name"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span class="optional">
                                                <xsl:choose>
                                                    <xsl:when test="preceding-sibling::wadl:param">&amp;</xsl:when>
                                                    <xsl:otherwise>?</xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:value-of select="@name"/>
                                            </span>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </h3>
                    <xsl:apply-templates select="wadl:doc"/>
                    <xsl:if test="wadl:param">
                        <h6>Path Parameters</h6>
                        <table>
                            <th>parameter</th>
                            <th>value</th>
                            <th>description</th>
                            <xsl:apply-templates select="ancestor-or-self::wadl:resource/wadl:param"/>
                        </table>
                    </xsl:if>
                    <h6>Allowed Methods</h6>
                    <div class="methods">
                        <xsl:apply-templates select="wadl:method"/>
                    </div>
                </div>
                <xsl:apply-templates select="wadl:resource" mode="list">
                    <xsl:with-param name="context" select="$name"/>
                </xsl:apply-templates>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
            
    <xsl:template match="wadl:method">
        <xsl:variable name="id"><xsl:call-template name="get-id"/></xsl:variable>
        <div class="method">
            <h4 id="{$id}">
                <xsl:value-of select="@name"/>
                <xsl:if test="wadl:doc[@title]">
                    &#x2013; <xsl:value-of select="wadl:doc[@title][1]/@title"/>
                </xsl:if>
            </h4>
            <xsl:apply-templates select="wadl:doc"/>                
            <xsl:apply-templates select="wadl:request"/>
            <xsl:apply-templates select="wadl:response"/>
        </div>
    </xsl:template>

    <xsl:template match="wadl:request">
        <xsl:if test="wadl:param">
            <h6>Query Parameters</h6>
            <table>
                <th>parameter</th>
                <th>value</th>
                <th>description</th>
                <xsl:apply-templates select="wadl:param"/>
            </table>
        </xsl:if>
        <xsl:if test="wadl:representation">
            <p><em>Acceptable Request Representations:</em></p>
            <ul>
                <xsl:apply-templates select="wadl:representation"/>
            </ul>
        </xsl:if>
    </xsl:template>

    <xsl:template match="wadl:response">
        <xsl:if test="wadl:representation">
            <p><em>Available Response Representations:</em></p>
            <ul>
                <xsl:apply-templates select="wadl:representation"/>
            </ul>
        </xsl:if>
        <xsl:if test="wadl:fault">
            <p><em>Potential Faults:</em></p>
            <ul>
                <xsl:apply-templates select="wadl:fault"/>
            </ul>
        </xsl:if>
    </xsl:template>


    <xsl:template match="wadl:representation">
        <xsl:variable name="id"><xsl:call-template name="get-id"/></xsl:variable>
        <li>
            <a href="#{$id}">
                <xsl:call-template name="representation-name"/>
            </a>
        </li>
    </xsl:template>    

    <xsl:template match="wadl:representation" mode="toc">
        <xsl:variable name="id"><xsl:call-template name="get-id"/></xsl:variable>
        <xsl:variable name="href" select="@id"/>
        <xsl:choose>
            <xsl:when test="preceding::wadl:representation[@id=$href]"/>
            <xsl:otherwise>               
                <li>
                    <a href="#{$id}">
                        <xsl:call-template name="representation-name"/>
                    </a>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
    <xsl:template match="wadl:representation" mode="list">
        <xsl:variable name="id"><xsl:call-template name="get-id"/></xsl:variable>
        <xsl:variable name="href" select="@id"/>
        <xsl:choose>
            <xsl:when test="preceding::wadl:representation[@id=$href]"/>
            <xsl:otherwise>
                <h3 id="{$id}">
                    <xsl:call-template name="representation-name"/>
                </h3>
                <xsl:apply-templates select="wadl:doc"/>                
                <div class="representation">
                    <xsl:if test="@element">
                        <h6>XML Schema</h6>
                        <xsl:call-template name="get-element">
                            <xsl:with-param name="context" select="."/>
                            <xsl:with-param name="qname" select="@element"/>
                        </xsl:call-template>
                    </xsl:if>        
                    <xsl:if test="wadl:param">
                        <h6>Representation Parameters</h6>
                        <table>
                            <th>parameter</th>
                            <th>value</th>
                            <th>description</th>                            
                            <xsl:apply-templates select="wadl:param"/>
                        </table>
                    </xsl:if>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="wadl:fault">
        <xsl:variable name="id"><xsl:call-template name="get-id"/></xsl:variable>
        <xsl:variable name="expanded-name">
            <xsl:call-template name="expand-qname">
                <xsl:with-param select="@element" name="qname"/>
            </xsl:call-template>
        </xsl:variable>
        <li>
            <a href="#{$id}">
                <xsl:choose>
                    <xsl:when test="wadl:doc[@title]">
                        <xsl:value-of select="wadl:doc[@title][1]/@title"/> 
                        (<xsl:value-of select="@status"/><xsl:text> - </xsl:text>
                        <xsl:value-of select="@mediaType"/>
                        <xsl:if test="@element">
                            <xsl:text> - </xsl:text>
                            <abbr title="{$expanded-name}"><xsl:value-of select="@element"/></abbr>
                        </xsl:if>)                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@status"/><xsl:text> - </xsl:text>
                        <xsl:value-of select="@mediaType"/>
                        <xsl:if test="@element"><xsl:text> - </xsl:text>
                            <abbr title="{$expanded-name}"><xsl:value-of select="@element"/></abbr>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </a>
        </li>
    </xsl:template>    
    
    <xsl:template match="wadl:fault" mode="list">
        <xsl:variable name="id"><xsl:call-template name="get-id"/></xsl:variable>
        <xsl:variable name="expanded-name">
            <xsl:call-template name="expand-qname">
                <xsl:with-param select="@element" name="qname"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="href" select="@id"/>
        <xsl:choose>
            <xsl:when test="preceding::wadl:fault[@id=$href]"/>
            <xsl:otherwise>
                <h3 id="{$id}">
                    <xsl:choose>
                        <xsl:when test="wadl:doc[@title]">
                            <xsl:value-of select="wadl:doc[@title][1]/@title"/> 
                            (<xsl:value-of select="@status"/><xsl:text> - </xsl:text>
                            <xsl:value-of select="@mediaType"/>
                            <xsl:if test="@element">
                                <xsl:text> - </xsl:text>
                                <abbr title="{$expanded-name}"><xsl:value-of select="@element"/></abbr>
                            </xsl:if>)
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@status"/><xsl:text> - </xsl:text>
                            <xsl:value-of select="@mediaType"/>
                            <xsl:if test="@element"><xsl:text> - </xsl:text>
                                <abbr title="{$expanded-name}"><xsl:value-of select="@element"/></abbr>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </h3>
                <xsl:apply-templates select="wadl:doc"/>
                <xsl:if test="@element or wadl:param">
                    <div class="representation">
                        <xsl:if test="@element">
                            <h6>XML Schema</h6>
                            <xsl:call-template name="get-element">
                                <xsl:with-param name="context" select="."/>
                                <xsl:with-param name="qname" select="@element"/>
                            </xsl:call-template>
                        </xsl:if>        
                        <xsl:if test="wadl:param">
                            <h6>Representation Variables</h6>
                            <dl>
                                <xsl:apply-templates select="wadl:param"/>
                            </dl>
                        </xsl:if>
                    </div>
                </xsl:if>                
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template match="wadl:param">
        <tr>
            <td>
                <p><var><xsl:value-of select="@name"/></var></p>
            </td>
            <td>
                <p>
                <em><xsl:call-template name="link-qname"><xsl:with-param name="qname" select="@type"/></xsl:call-template></em>
                    <xsl:if test="@style"> <small> (<xsl:value-of select="@style"/>)</small></xsl:if>
                    <xsl:if test="@required='true'"> <small> (required)</small></xsl:if>
                    <xsl:if test="@repeating='true'"> <small> (repeating)</small></xsl:if>            
                </p>
                <xsl:choose>
                    <xsl:when test="wadl:option">
                        <p><em>One of:</em></p>
                        <ul>
                            <xsl:apply-templates select="wadl:option"/>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="@default"><p>Default: <code><xsl:value-of select="@default"/></code></p></xsl:if>
                        <xsl:if test="@fixed"><p>Fixed: <code><xsl:value-of select="@fixed"/></code></p></xsl:if>
                    </xsl:otherwise>
                </xsl:choose>                        
            </td>
            <td>
                <xsl:apply-templates select="wadl:doc"/>
                <xsl:if test="@path"><p>XPath to value: <code><xsl:value-of select="@path"/></code></p></xsl:if>
            </td>
        </tr>                
    </xsl:template>

    <xsl:template match="wadl:option">
        <li>
            <code><xsl:value-of select="@value"/></code>
            <xsl:if test="ancestor::wadl:param[1]/@default=@value"> <small> (default)</small></xsl:if>
            <xsl:if test="wadl:doc"> - <xsl:apply-templates select="wadl:doc"><xsl:with-param name="inline">1</xsl:with-param></xsl:apply-templates></xsl:if>
        </li>
    </xsl:template>    

    <xsl:template match="wadl:doc">
        <xsl:param name="inline">0</xsl:param>
        <!-- skip WADL elements -->
        <xsl:choose>
            <xsl:when test="node()[1]=text() and $inline=0">
                <p>
                    <xsl:apply-templates select="node()" mode="copy"/>
                </p>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="node()" mode="copy"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- utilities -->

    <xsl:template name="get-id">
        <xsl:choose>
            <xsl:when test="@id"><xsl:value-of select="@id"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="generate-id()"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get-element">
        <xsl:param name="context" select="."/>
        <xsl:param name="qname"/>
        <xsl:variable name="qname-ns-uri" select="ancestor-or-self::*/namespace::*[name()=substring-before($qname, ':')][1]"/>
        <xsl:variable name="localname" select="substring-after($qname, ':')"/>
        <xsl:variable name="definition" select="$grammars/descendant::xs:element[@name=$localname][ancestor-or-self::*[@targetNamespace=$qname-ns-uri]]"/>
        <xsl:variable name='source' select="$definition/ancestor-or-self::wadl:include[1]/@href"/>
        <p><em>Source: <a href="{$source}"><xsl:value-of select="$source"/></a></em></p>
        <pre><xsl:apply-templates select="$definition" mode="encode"/></pre>
    </xsl:template>

    <xsl:template name="link-qname">
        <xsl:param name="context" select="."/>
        <xsl:param name="qname"/>
        <xsl:variable name="qname-ns-uri" select="$context/ancestor-or-self::*/namespace::*[name()=substring-before($qname, ':')][1]"/>
        <xsl:variable name="localname" select="substring-after($qname, ':')"/>
        <xsl:choose>
            <xsl:when test="$qname-ns-uri='http://www.w3.org/2001/XMLSchema'">
                <a href="http://www.w3.org/TR/xmlschema-2/#{$localname}"><xsl:value-of select="$localname"/></a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="definition" select="$grammars/descendant::xs:*[@name=$localname][ancestor-or-self::*[@targetNamespace=$qname-ns-uri]]"/>                
                <a href="{$definition/ancestor-or-self::wadl:include[1]/@href}" title="{$definition/descendant::xs:documentation/descendant::text()}"><xsl:value-of select="$localname"/></a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="expand-qname">
        <xsl:param name="context" select="."/>
        <xsl:param name="qname"/>
        <xsl:variable name="qname-ns-uri" select="$context/ancestor-or-self::*/namespace::*[name()=substring-before($qname, ':')][1]"/>
        <xsl:text>{</xsl:text>
        <xsl:value-of select="$qname-ns-uri"/>} <xsl:value-of select="substring-after($qname, ':')"/>
    </xsl:template>
        
    
    <xsl:template name="representation-name">
        <xsl:variable name="expanded-name">
            <xsl:call-template name="expand-qname">
                <xsl:with-param select="@element" name="qname"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="wadl:doc[@title]">
                <xsl:value-of select="wadl:doc[@title][1]/@title"/> 
                (<xsl:value-of select="@mediaType"/>)
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@mediaType"/><xsl:text> (</xsl:text>
                <abbr title="{$expanded-name}"><xsl:value-of select="@element"/></abbr>)
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>        
        
    <!-- entity-encode markup for display -->

    <xsl:template match="*" mode="encode">
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="name()"/><xsl:apply-templates select="attribute::*" mode="encode"/>
        <xsl:choose>
            <xsl:when test="*|text()">
                <xsl:text>&gt;</xsl:text>
                <xsl:apply-templates select="*|text()" mode="encode" xml:space="preserve"/>
                <xsl:text>&lt;/</xsl:text><xsl:value-of select="name()"/><xsl:text>&gt;</xsl:text>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>/&gt;</xsl:text>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:template>            
    
    <xsl:template match="attribute::*" mode="encode">
        <xsl:text> </xsl:text><xsl:value-of select="name()"/><xsl:text>="</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text>
    </xsl:template>    
    
    <xsl:template match="text()" mode="encode">
        <xsl:value-of select="." xml:space="preserve"/>
    </xsl:template>    

    <!-- copy HTML for display -->
    
    <xsl:template match="html:*" mode="copy">
        <!-- remove the prefix on HTML elements -->
        <xsl:element name="{local-name()}">
            <xsl:for-each select="@*">
                <xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
            </xsl:for-each>
            <xsl:apply-templates select="node()" mode="copy"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*|node()[namespace-uri()!='http://www.w3.org/1999/xhtml']" mode="copy">
        <!-- everything else goes straight through -->
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="copy"/>
        </xsl:copy>
    </xsl:template>    

</xsl:stylesheet>
