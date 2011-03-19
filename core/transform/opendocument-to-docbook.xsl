<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:db="http://docbook.org/ns/docbook" xmlns:docvert="docvert:5" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink">

<xsl:output method="xml" omit-xml-declaration="no"/>

<!-- <xsl:key name='heading-children' match="*[not(self::text:h or self::text:section)]" use="generate-id((..|preceding-sibling::text:h[@text:outline-level='1']|preceding-sibling::text:h[@text:outline-level='2']|preceding-sibling::text:h[@text:outline-level='3']|preceding-sibling::text:h[@text:outline-level='4']|preceding-sibling::text:h[@text:outline-level='5']|preceding-sibling::text:h[@text:outline-level='6'])[last()])"/> -->
<xsl:key name='heading-children' match="text:p | table:table | text:ordered-list | text:list | draw:frame | draw:image | svg:desc | office:annotation | text:unordered-list | text:footnote | text:a | text:list-item | draw:plugin | draw:text-box | text:footnote-body | text:section" use="generate-id((..|preceding-sibling::text:h[@text:outline-level='1']|preceding-sibling::text:h[@text:outline-level='2']|preceding-sibling::text:h[@text:outline-level='3']|preceding-sibling::text:h[@text:outline-level='4']|preceding-sibling::text:h[@text:outline-level='5']|preceding-sibling::text:h[@text:outline-level='6'])[last()])"/>
<xsl:key name="children" match="text:h[@text:outline-level &gt; 1]" use="generate-id(preceding-sibling::text:h[@text:outline-level &lt; current()/@text:outline-level][1])"/>

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
            <xsl:apply-templates select="*[not(self::text:h) and not(preceding-sibling::text:h)]"/>
            <xsl:if test="not(//text:h[@text:outline-level='1'])"><xsl:apply-templates select="//text:h"/></xsl:if>
            <xsl:if test="not(//text:h)"><xsl:apply-templates/></xsl:if>
        </xsl:element>
        <xsl:apply-templates select="text:h[@text:outline-level='1']"/>
    </xsl:element>
</xsl:template>

<xsl:template match="text:h[@text:outline-level='1']">
    <xsl:variable name="outline-level" select="@text:outline-level"/>
    <xsl:call-template name="section">
        <xsl:with-param name="outline-level" select="$outline-level"/>
        <xsl:with-param name="previous-outline-level" select="1"/>
    </xsl:call-template>
</xsl:template>

<xsl:template name="section">
    <xsl:param name="outline-level"/>
    <xsl:param name="previous-outline-level"/>
    <xsl:choose>
        <xsl:when test="$outline-level &gt; $previous-outline-level + 1">
            <xsl:text disable-output-escaping="yes">&lt;db:sect</xsl:text>
            <xsl:value-of select="$previous-outline-level"/>
            <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
            <xsl:call-template name="section">
                <xsl:with-param name="outline-level" select="$outline-level"/>
                <xsl:with-param name="previous-outline-level" select="$previous-outline-level + 1"/>
            </xsl:call-template>
            <xsl:text disable-output-escaping="yes">&lt;/db:sect</xsl:text>
            <xsl:value-of select="$previous-outline-level"/>
            <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        </xsl:when>
        <xsl:when test="$outline-level = 1">
            <xsl:element name="db:chapter">
                <xsl:element name="db:title"><xsl:apply-templates/></xsl:element>
                <xsl:apply-templates select="key('heading-children', generate-id())"/>
                <xsl:apply-templates select="key('children', generate-id())"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text disable-output-escaping="yes">&lt;db:sect</xsl:text>
            <xsl:value-of select="$outline-level - 1"/>
            <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
            <xsl:element name="db:title"><xsl:apply-templates/></xsl:element>
            <xsl:call-template name="section">
                <xsl:with-param name="outline-level" select="$outline-level"/>
                <xsl:with-param name="previous-outline-level" select="$previous-outline-level + 1"/>
            </xsl:call-template>
            <xsl:text disable-output-escaping="yes">&lt;/db:sect</xsl:text>
            <xsl:value-of select="$outline-level - 1"/>
            <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="text:footnote-body | text:note-body | draw:text-box">
        <xsl:apply-templates/>
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

<xsl:template match="draw:image">
    <xsl:element name="db:mediaobject">
        <xsl:element name="db:imageobject">
            <xsl:element name="db:imagedata">
                <xsl:attribute name="fileref"><xsl:value-of select="@xlink:href"/></xsl:attribute>
                <xsl:attribute name="format">
                    <xsl:choose>
                        <xsl:when test="@format"><xsl:value-of select="@format"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="substring-after(@xlink:href, '.')"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
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


</xsl:stylesheet>

