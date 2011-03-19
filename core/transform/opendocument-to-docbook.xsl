<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:db="http://docbook.org/ns/docbook" xmlns:docvert="docvert:5" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0">

<xsl:output method="xml" omit-xml-declaration="no"/>

<!-- <xsl:key name='heading-children' match="*[not(self::text:h or self::text:section)]" use="generate-id((..|preceding-sibling::text:h[@text:outline-level='1']|preceding-sibling::text:h[@text:outline-level='2']|preceding-sibling::text:h[@text:outline-level='3']|preceding-sibling::text:h[@text:outline-level='4']|preceding-sibling::text:h[@text:outline-level='5']|preceding-sibling::text:h[@text:outline-level='6'])[last()])"/> -->
<xsl:key name='heading-children' match="text:p | table:table | text:ordered-list | text:list | draw:frame | draw:image | svg:desc | office:annotation | text:unordered-list | text:footnote | text:a | text:list-item | draw:plugin | draw:text-box | text:footnote-body | text:section" use="generate-id((..|preceding-sibling::text:h[@text:outline-level='1']|preceding-sibling::text:h[@text:outline-level='2']|preceding-sibling::text:h[@text:outline-level='3']|preceding-sibling::text:h[@text:outline-level='4']|preceding-sibling::text:h[@text:outline-level='5']|preceding-sibling::text:h[@text:outline-level='6'])[last()])"/>

<xsl:key name="children" match="text:h[@text:outline-level &gt; 1]" use="generate-id(preceding-sibling::text:h[@text:outline-level &lt; current()/@text:outline-level][1])"/>

<xsl:template match="/docvert:root">
    <xsl:apply-templates select="docvert:external-file[@docvert:name='content.xml']"/>
</xsl:template>

<xsl:template match="office:text">
    <xsl:element name="db:book">
        <xsl:attribute name="version">
                <xsl:text>5.0</xsl:text>
        </xsl:attribute>
        <xsl:element name="db:preface">
            <xsl:apply-templates select="key('heading-children', generate-id())"/>
            <xsl:apply-templates select="*[not(self::text:h) and not(preceding-sibling::text:h)]"/>
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
                 <xsl:apply-templates select="key('heading-children', generate-id())"/>
                 <xsl:apply-templates select="key('children', generate-id())"/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text disable-output-escaping="yes">&lt;db:sect</xsl:text>
            <xsl:value-of select="$outline-level - 1"/>
            <xsl:text disable-output-escaping="yes">&gt;</xsl:text>
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

</xsl:stylesheet>

