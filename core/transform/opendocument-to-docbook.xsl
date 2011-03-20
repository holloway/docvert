<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:db="http://docbook.org/ns/docbook" xmlns:docvert="docvert:5" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:output method="xml" omit-xml-declaration="no"/>

<!-- <xsl:key name='heading-children' match="*[not(self::text:h or self::text:section)]" use="generate-id((..|preceding-sibling::text:h[@text:outline-level='1']|preceding-sibling::text:h[@text:outline-level='2']|preceding-sibling::text:h[@text:outline-level='3']|preceding-sibling::text:h[@text:outline-level='4']|preceding-sibling::text:h[@text:outline-level='5']|preceding-sibling::text:h[@text:outline-level='6'])[last()])"/> -->
<xsl:key name='heading-children' match="text:p | table:table | text:ordered-list | text:list | draw:frame | draw:image | svg:desc | office:annotation | text:unordered-list | text:footnote | text:a | text:list-item | draw:plugin | draw:text-box | text:footnote-body | text:section" use="generate-id((..|preceding-sibling::text:h[@text:outline-level='1']|preceding-sibling::text:h[@text:outline-level='2']|preceding-sibling::text:h[@text:outline-level='3']|preceding-sibling::text:h[@text:outline-level='4']|preceding-sibling::text:h[@text:outline-level='5']|preceding-sibling::text:h[@text:outline-level='6'])[last()])"/>

<xsl:key name="styles-by-name" match="//style:style" use="@style:name"/>
<xsl:key name="elements-by-style-name" match="//*" use="@text:style-name"/>
<xsl:variable name="lowercase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="uppercase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>


<xsl:template match="/docvert:root">
    <xsl:apply-templates select="docvert:external-file[@docvert:name='content.xml']"/>
</xsl:template>

<xsl:template match="office:text">
    <xsl:element name="db:book">
        <xsl:attribute name="version">5.0</xsl:attribute>
        <xsl:element name="db:preface">
            <xsl:apply-templates select="key('heading-children', generate-id())"/>
            <xsl:if test="not(//text:h[@text:outline-level='1'])"><xsl:apply-templates select="//text:h"/></xsl:if>
            <xsl:if test="not(//text:h)">[<xsl:apply-templates/>]</xsl:if>
        </xsl:element>
        <xsl:apply-templates select="text:h[@text:outline-level='1']"/>
    </xsl:element>
</xsl:template>

<xsl:template match="text:h[@text:outline-level='1']">
    <xsl:call-template name="section">
        <xsl:with-param name="outline-level" select="@text:outline-level"/>
        <xsl:with-param name="previous-outline-level" select="1"/>
    </xsl:call-template>
</xsl:template>

<xsl:template match="text:h">
    <xsl:variable name="outline-level" select="@text:outline-level"/>
    <xsl:call-template name="section">
        <xsl:with-param name="outline-level" select="$outline-level"/>
        <xsl:with-param name="previous-outline-level" select="preceding-sibling::text:h[@text:outline-level &lt; $outline-level][1]/@text:outline-level"/>
    </xsl:call-template>
</xsl:template>

<xsl:template name="section">
    <xsl:param name="outline-level"/>
    <xsl:param name="previous-outline-level"/>
    <xsl:choose>
        <xsl:when test="$outline-level &gt; $previous-outline-level + 1">
            <xsl:call-template name="draw-section-level">
                <xsl:with-param name="descend-sections-or-apply-templates" select="'descend-sections'"/>
                <xsl:with-param name="outline-level" select="$outline-level"/>
                <xsl:with-param name="previous-outline-level" select="$previous-outline-level"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:call-template name="draw-section-level">
                <xsl:with-param name="descend-sections-or-apply-templates" select="'apply-templates'"/>
                <xsl:with-param name="outline-level" select="$outline-level"/>
                <xsl:with-param name="previous-outline-level" select="$previous-outline-level"/>
            </xsl:call-template>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="text:p">
    <xsl:if test="normalize-space(.) or descendant::draw:frame">
        <xsl:element name="db:para">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:if>
</xsl:template>

<xsl:template match="text:line-break">
    <xsl:element name="db:sbr"/>
</xsl:template>

<xsl:template match="text:a">
    <xsl:element name="db:link">
        <xsl:attribute name="xlink:href"><xsl:value-of select="@xlink:href"/></xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="text:span">
    <xsl:variable name="text-style" select="key('styles-by-name', @text:style-name)"/>
    <xsl:choose>
        <xsl:when test="@text:style-name='Emphasis'">
            <xsl:element name="db:emphasis">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:when>
        <xsl:when test="contains($text-style/style:text-properties/@style:text-position, 'sub')">
            <xsl:element name="db:subscript">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:when>
        <xsl:when test="contains($text-style/style:text-properties/@style:text-position, 'super')">
            <xsl:element name="db:superscript">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:apply-templates/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="draw:frame/draw:image">
    <xsl:element name="db:mediaobject">
        <xsl:element name="db:imageobject">
            <xsl:element name="db:imagedata">
                <xsl:attribute name="fileref"><xsl:value-of select="@xlink:href"/></xsl:attribute>
                <xsl:attribute name="height"><xsl:value-of select="parent::*/@svg:width"/></xsl:attribute>
                <xsl:attribute name="depth"><xsl:value-of select="parent::*/@svg:height"/></xsl:attribute>
                <xsl:attribute name="fileref"><xsl:value-of select="@xlink:href"/></xsl:attribute>
            </xsl:element>
        </xsl:element>
    </xsl:element>
</xsl:template>

<xsl:template match="text:bookmark-start">
    <xsl:element name="db:anchor">
        <xsl:attribute name="xml:id"><xsl:value-of select="@text:name"/></xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="table:table">
    <xsl:element name="db:table">
        <xsl:apply-templates/>                  
    </xsl:element>
</xsl:template>

<xsl:template match="table:table-row">
    <xsl:element name="db:row">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="table:table-cell">
    <xsl:element name="db:entry">
        <xsl:if test="@table:number-columns-spanned"><xsl:attribute name="colspan"><xsl:value-of select="@table:number-columns-spanned"/></xsl:attribute></xsl:if>
        <xsl:if test="@table:number-rows-spanned"><xsl:attribute name="rowspan"><xsl:value-of select="@table:number-rows-spanned"/></xsl:attribute></xsl:if>
        <xsl:if test="descendant::text:p[@text:class-names='table-heading']"><xsl:attribute name="role">heading</xsl:attribute></xsl:if>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template name="draw-section-level">
    <xsl:param name="descend-sections-or-apply-templates"/>
    <xsl:param name="outline-level"/>
    <xsl:param name="previous-outline-level"/>
    <xsl:choose>
        <xsl:when test="$outline-level - 1 = 0">
            <xsl:element name="db:chapter"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
        </xsl:when>
        <xsl:when test="$outline-level - 1 = 1">
            <xsl:element name="db:sect1"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
        </xsl:when>
        <xsl:when test="$outline-level - 1 = 2">
            <xsl:element name="db:sect2"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
        </xsl:when>
        <xsl:when test="$outline-level - 1 = 3">
            <xsl:element name="db:sect3"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
        </xsl:when>
        <xsl:when test="$outline-level - 1 = 4">
            <xsl:element name="db:sect4"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
        </xsl:when>
        <xsl:when test="$outline-level - 1 = 5">
            <xsl:element name="db:sect5"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
        </xsl:when>
        <xsl:when test="$outline-level - 1 = 6">
            <xsl:element name="db:sect6"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
        </xsl:when>
        <xsl:when test="$outline-level - 1 = 7">
            <xsl:element name="db:sect7"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
        </xsl:when>
        <xsl:when test="$outline-level - 1 = 8">
            <xsl:element name="db:sect8"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="db:sect9"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="draw-section-children">
    <xsl:param name="descend-sections-or-apply-templates"/>
    <xsl:param name="outline-level"/>
    <xsl:param name="previous-outline-level"/>
    <xsl:choose>
        <xsl:when test="$descend-sections-or-apply-templates = 'descend sections'">
            <xsl:call-template name="section">
                <xsl:with-param name="outline-level" select="$outline-level"/>
                <xsl:with-param name="previous-outline-level" select="$previous-outline-level + 1"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="db:title"><xsl:apply-templates/></xsl:element>
            <xsl:apply-templates select="key('heading-children', generate-id())"/>
            <xsl:call-template name="apply-templates-children-headings"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="apply-templates-children-headings">
    <!--
    Temporary workaround until we can write xsl:keys for this function.
    TODO: can't use current() in patterns such as xsl:key http://www.w3.org/TR/xslt#function-current
    -->
    <xsl:variable name="generate-id" select="generate-id()"/>
    <xsl:variable name="outline-level" select="number(@text:outline-level)"/>
    <xsl:for-each select="following-sibling::text:h">
        <xsl:variable name="subheading-outline-level" select="@text:outline-level"/>
        <xsl:variable name="first-preceding-heading" select="./preceding-sibling::text:h[@text:outline-level &lt; $subheading-outline-level][1]"/>
        <xsl:if test="generate-id($first-preceding-heading) = $generate-id">
            <xsl:apply-templates select="."/>
        </xsl:if>
    </xsl:for-each>
</xsl:template>


</xsl:stylesheet>
