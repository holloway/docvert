<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook" xmlns="http://www.w3.org/1999/xhtml" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="db html xlink">

<xsl:output method="xml" version="1.0" encoding="utf-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" omit-xml-declaration="yes"/>

<xsl:param name="withTableOfContents"/>

<xsl:variable name="lowercase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="uppercase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
<xsl:variable name="numbers">0123456789</xsl:variable>
<xsl:variable name="numberswithdot">0123456789.</xsl:variable>

<xsl:template match="/db:book">
    <html lang="en">
        <head>
            <title>
                <xsl:choose>
                    <xsl:when test="/db:book/db:preface and /db:book/db:chapter">
                        <xsl:value-of select="/db:book/db:title"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="/db:book/db:preface/db:title"/>
                        <xsl:value-of select="/db:book/db:chapter/db:title"/>
                        <xsl:if test="/db:book/db:title and normalize-space(/db:book/db:title) != '[no title]' ">
                            <xsl:if test="/db:book/db:preface/db:title or /db:book/db:chapter/db:title">
                                <xsl:text> - </xsl:text>
                            </xsl:if>
                            <xsl:value-of select="/db:book/db:title"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text> </xsl:text>
            </title>
        </head>
        <body>
            <xsl:if test="$withTableOfContents">
                <xsl:apply-templates select="db:toc"/>
            </xsl:if>
            <xsl:apply-templates select="db:GUIMenu[not(@id='nextPreviousMenu')]"/>
            <div class="page">
                <xsl:apply-templates select="*[not(self::db:toc or self::db:GUIMenu)]"/>
                <xsl:call-template name="drawFootNoteContent"/>
            </div>
            <xsl:apply-templates select="db:GUIMenu[@id='nextPreviousMenu']"/>

        </body>
    </html>
</xsl:template>

<xsl:template match="db:toc | db:abstract | db:info"/>

<xsl:template match="db:book/db:title">
        <xsl:if test="/db:book/db:preface/db:title or /db:book/db:chapter/db:title">
            <p class="pageTitle">
                <xsl:value-of select="/db:book/db:preface/db:title"/>
                <xsl:if test="/db:book/db:preface/db:title and /db:book/db:chapter/db:title">
                    <xsl:text> - </xsl:text>
                </xsl:if>
                <xsl:value-of select="/db:book/db:chapter/db:title"/>
                <xsl:if test="not(normalize-space(concat(/db:book/db:chapter/db:title, /db:book/db:preface/db:title)))">
                    <xsl:text>&#160;</xsl:text>
                </xsl:if>
            </p>
        </xsl:if>
        <xsl:if test="/db:book/db:title and normalize-space(/db:book/db:title) != '[no title]' ">
            <p class="documentTitle">
                <xsl:value-of select="/db:book/db:title"/>
            </p>
        </xsl:if>
</xsl:template>

<xsl:template match="db:toc">
    <div id="tableOfContents">
        <h1>Table of Contents</h1>
        <ul>
            <xsl:apply-templates select="db:tocentry"/>
        </ul>
    </div>
</xsl:template>

<xsl:template match="db:tocentry">
    <li>
        <xsl:apply-templates/>
        <xsl:apply-templates select="following-sibling::*[1][self::db:tocchap]"/>
    </li>
</xsl:template>

<xsl:template match="db:tocchap">
    <ul>
        <xsl:apply-templates/>
    </ul>
</xsl:template>


<xsl:template match="db:literallayout">
    <xsl:element name="pre">
            <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="db:literal[@role='additionalSpace']">
     <xsl:text>&#160;</xsl:text>
</xsl:template>

<xsl:template match="db:footnote">
    <sup class="footnote">
        <a>
            <xsl:attribute name="href">#footnote-<xsl:value-of select="@label"/></xsl:attribute>
            <xsl:attribute name="name">source-of-footnote-<xsl:value-of select="@label"/></xsl:attribute>
            <xsl:attribute name="title">Footnote <xsl:value-of select="@label"/></xsl:attribute>
            <xsl:value-of select="@label"/>
        </a>
    </sup>
</xsl:template>

<xsl:template match="db:footnote/db:para[count(preceding-sibling::db:para) = 0]" role="footnoteText">
    <xsl:variable name="footnoteLabel" select="parent::db:footnote/@label"/>
    <p>
        <a>
            <xsl:attribute name="name">footnote-<xsl:value-of select="$footnoteLabel"/></xsl:attribute>
            <xsl:attribute name="href">#source-of-footnote-<xsl:value-of select="$footnoteLabel"/></xsl:attribute>
            <xsl:attribute name="title">Back to footnote reference <xsl:value-of select="$footnoteLabel"/></xsl:attribute>
            <xsl:value-of select="$footnoteLabel"/>
        </a>:
        <xsl:apply-templates/>
    </p>
</xsl:template>

<xsl:template name="drawFootNoteContent">
    <xsl:if test="//db:footnote">
        <div id="footnotes">
            <xsl:for-each select="//db:footnote">
                <div class="footnote">
                    <xsl:apply-templates role="footnoteText"/>
                </div>
            </xsl:for-each>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="db:link">
    <xsl:element name="a">
        <xsl:attribute name="href">
            <xsl:value-of select="@xlink:href"/>
        </xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="db:anchor">
    <xsl:element name="a">
        <xsl:attribute name="name">
            <xsl:value-of select="@xml:id"/>
        </xsl:attribute>
        <xsl:attribute name="id">
            <xsl:value-of select="@xml:id"/>
        </xsl:attribute>
    </xsl:element>
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="db:itemizedlist | db:list">
        <ul><xsl:apply-templates/></ul>
</xsl:template>

<xsl:template match="db:orderedlist">
    <xsl:element name="ol">
        <xsl:if test="@continuation">
            <xsl:variable name="depth" select="count(ancestor::db:orderedlist)"/>
            <xsl:attribute name="start">
                <xsl:variable name="preceding-list-items-in-this-continuation">
                    <xsl:call-template name="count-list-items">
                        <xsl:with-param name="current-list" select="."/>
                        <xsl:with-param name="depth" select="$depth"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="db:listitem/*[not(self::db:orderedlist[@continuation])]">
                        <xsl:value-of select="number($preceding-list-items-in-this-continuation) + 1"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>1</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template name="count-list-items">
    <xsl:param name="current-list"/>
    <xsl:param name="depth"/>
    <xsl:param name="amount-of-list-items" select="0"/>
    <xsl:choose>
        <xsl:when test="$current-list[@continuation]">
            <xsl:variable name="previous-list" select="$current-list/preceding::db:orderedlist[count(ancestor::db:orderedlist)=$depth][1]"/>
            <xsl:call-template name="count-list-items">
                <xsl:with-param name="depth" select="$depth"/>
                <xsl:with-param name="current-list" select="$previous-list"/>
                <xsl:with-param name="amount-of-list-items" select="$amount-of-list-items + count($previous-list/db:listitem)"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$amount-of-list-items"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="db:listitem">
    <xsl:element name="li">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="db:para">
    <xsl:element name="p">
        <xsl:if test="contains(@role, 'dc.')">
            <xsl:attribute name="class">
                <xsl:value-of select="translate(@role, '.', '-')"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="db:chapter/db:title">
    <xsl:element name="h1">
        <xsl:if test="@db:id">
            <xsl:attribute name="id"><xsl:value-of select="@db:id"/></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="not(normalize-space(descendant::text()))"><xsl:text> </xsl:text></xsl:if>
    </xsl:element>
</xsl:template>

<xsl:template match="db:preface/db:title">
    <xsl:element name="h1">
        <xsl:attribute name="class">documentTitle</xsl:attribute>
        <xsl:if test="@db:id">
            <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="not(normalize-space(descendant::text()))"><xsl:text> </xsl:text></xsl:if>
    </xsl:element>
</xsl:template>

<xsl:template match="db:chapter | db:sect1 | db:sect2 | db:sect3 | db:sect4 | db:sect5 | db:sect6 | db:sect7 | db:sect8 | db:sect9">
    <xsl:element name="div">
        <xsl:attribute name="class"><xsl:value-of select="local-name()"/></xsl:attribute>
        <xsl:if test="@db:id"><xsl:attribute name="id"><xsl:value-of select="@db:id"/></xsl:attribute></xsl:if>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="db:sect1/db:title">
    <xsl:element name="h2">
        <xsl:if test="@db:id">
            <xsl:attribute name="id"><xsl:value-of select="@db:id"/></xsl:attribute>
            <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute></xsl:element>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="not(normalize-space(descendant::text()))"><xsl:text> </xsl:text></xsl:if>
    </xsl:element>
</xsl:template>

<xsl:template match="db:sect2/db:title">
    <xsl:element name="h3">
        <xsl:if test="@db:id">
            <xsl:attribute name="id"><xsl:value-of select="@db:id"/></xsl:attribute>
            <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute></xsl:element>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="not(normalize-space(descendant::text()))"><xsl:text> </xsl:text></xsl:if>
    </xsl:element>
</xsl:template>

<xsl:template match="db:sect3/db:title">
    <xsl:element name="h4">
        <xsl:if test="@db:id">
            <xsl:attribute name="id"><xsl:value-of select="@db:id"/></xsl:attribute>
            <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute></xsl:element>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="not(normalize-space(descendant::text()))"><xsl:text> </xsl:text></xsl:if>
    </xsl:element>
</xsl:template>

<xsl:template match="db:sect4/db:title">
    <xsl:element name="h5">
        <xsl:if test="@db:id">
            <xsl:attribute name="id"><xsl:value-of select="@db:id"/></xsl:attribute>
            <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute></xsl:element>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="not(normalize-space(descendant::text()))"><xsl:text> </xsl:text></xsl:if>
    </xsl:element>
</xsl:template>

<xsl:template match="db:sect5/db:title | db:sect6/db:title | db:sect7/db:title | db:sect8/db:title | db:sect9/db:title">
    <xsl:element name="h6">
        <xsl:if test="@db:id">
            <xsl:attribute name="id"><xsl:value-of select="@db:id"/></xsl:attribute>
            <xsl:element name="a"><xsl:attribute name="name"><xsl:value-of select="@id"/></xsl:attribute></xsl:element>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="not(normalize-space(descendant::text()))"><xsl:text> </xsl:text></xsl:if>
    </xsl:element>
</xsl:template>

<xsl:template match="db:table">
    <xsl:element name="table">
        <xsl:if test="@db:id">
            <xsl:attribute name="id"><xsl:value-of select="@db:id"/></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="db:table/db:title">
    <xsl:if test="normalize-space(.) or *">
        <xsl:element name="caption">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:if>
</xsl:template>

<xsl:template match="db:row"><tr><xsl:apply-templates/></tr></xsl:template>

<xsl:template match="db:thead"><thead><xsl:apply-templates/></thead></xsl:template>

<xsl:template match="db:tfoot"><tfoot><xsl:apply-templates/></tfoot></xsl:template>

<xsl:template match="db:tbody"><tbody><xsl:apply-templates/></tbody></xsl:template>

<xsl:template match="db:row">
    <xsl:element name="tr">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="db:entry">
    <xsl:choose>
        <xsl:when test="ancestor::db:thead or @role='heading' ">
            <th>
                <xsl:if test="@colspan">
                    <xsl:attribute name="colspan"><xsl:value-of select="@colspan"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="@rowspan">
                    <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="@align">
                    <xsl:attribute name="class">align-<xsl:value-of select="@align"/></xsl:attribute>
                </xsl:if>
                <xsl:apply-templates/>
            </th>
        </xsl:when>
        <xsl:otherwise>
            <td>
                <xsl:if test="@colspan">
                    <xsl:attribute name="colspan"><xsl:value-of select="@colspan"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="@rowspan">
                    <xsl:attribute name="rowspan"><xsl:value-of select="@rowspan"/></xsl:attribute>
                </xsl:if>
                <xsl:if test="@align">
                    <xsl:attribute name="class">align-<xsl:value-of select="@align"/></xsl:attribute>
                </xsl:if>
                <xsl:apply-templates/>
            </td>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="db:mediaobject">
    <xsl:element name="img">
        <xsl:attribute name="src">
            <xsl:value-of select="descendant::db:imagedata/@fileref"/>
        </xsl:attribute>
        <xsl:attribute name="alt">
            <xsl:value-of select="descendant::db:caption"/>
        </xsl:attribute>
        <xsl:if test="descendant::db:imagedata/@depth and descendant::db:imagedata/@height">
            <xsl:attribute name="width">
                <xsl:call-template name="dimension-to-pixels">
                    <xsl:with-param name="size" select="descendant::db:imagedata/@depth"/>
                </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="height">
                <xsl:call-template name="dimension-to-pixels">
                    <xsl:with-param name="size" select="descendant::db:imagedata/@height"/>
                </xsl:call-template>
            </xsl:attribute>
        </xsl:if>
    </xsl:element>
</xsl:template>

<xsl:template match="db:sbr"><br/></xsl:template>

<xsl:template match="db:GUIMenu">
    <xsl:if test="normalize-space(.)">
        <div class="menu" id="{@id}">
            <xsl:if test="@id = 'pagesMenu' or @id = 'nextPreviousMenu' or @id = 'pageInternalMenu' ">
                <h1>
                    <xsl:choose>
                        <xsl:when test="@id = 'pagesMenu' ">Table of Contents</xsl:when>
                        <xsl:when test="@id = 'nextPreviousMenu' ">Page Navigation</xsl:when>
                        <xsl:when test="@id = 'pageInternalMenu' ">Within this page</xsl:when>
                    </xsl:choose>
                </h1>
            </xsl:if>
            <ul>
                <xsl:apply-templates/>
            </ul>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="db:emphasis">
    <xsl:choose>
        <xsl:when test="@role = 'bold' or @role = 'strong' ">
            <xsl:element name="strong">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="em">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="db:GUIMenuItem | db:GUISubMenu">
    <li>
        <xsl:apply-templates/>
        <xsl:if test="not(normalize-space(descendant::text()))">[no title]</xsl:if>
    </li>
</xsl:template>

<xsl:template match="db:inlinegraphic">
    <img src="{@fileref}" alt="{normalize-space(.)}"/>
</xsl:template>

<xsl:template match="html:div">
    <img src="{@fileref}" alt="{normalize-space(.)}"/>
</xsl:template>

<xsl:template name="dimension-to-pixels">
    <xsl:param name="size"/>
    <xsl:variable name="dpi">96</xsl:variable>
    <xsl:variable name="cm-to-inches" select=" number('0.393700787') "/>
    <xsl:variable name="mm-to-inches" select=" number('0.0393700787') "/>
    <xsl:variable name="units" select="translate($size, $numberswithdot, '')"/>
    <xsl:variable name="lowercase-units" select="translate($units, $uppercase, $lowercase)"/>
    <xsl:variable name="numbers" select="translate($size, concat($uppercase,$lowercase), '')"/>
    <xsl:choose>
        <xsl:when test="$lowercase-units = 'cm' "><xsl:value-of select=" round($numbers * $cm-to-inches * $dpi) "/></xsl:when>
        <xsl:when test="$lowercase-units = 'mm' "><xsl:value-of select=" round($numbers * $mm-to-inches * $dpi) "/></xsl:when>
        <xsl:when test="$lowercase-units = 'in' "><xsl:value-of select=" round($numbers * $dpi) "/></xsl:when>
        <xsl:when test="$lowercase-units = 'px' "><xsl:value-of select=" round($numbers) "/></xsl:when>
        <xsl:otherwise>
            <xsl:message terminate="yes">Unrecognised size of "<xsl:value-of select="$size"/>".</xsl:message>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
