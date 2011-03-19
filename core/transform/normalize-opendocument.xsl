<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0">

<xsl:output method="xml" omit-xml-declaration="no"/>

<xsl:key name="styles-by-name" match="//style:style" use="@style:name"/>
<xsl:key name="elements-by-style-name" match="//*" use="@text:style-name"/>

<xsl:variable name="lowercase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="uppercase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

<xsl:template match="text:p">
    <xsl:variable name="style" select="key('styles-by-name', @text:style-name)"/>
    <xsl:variable name="parent-style" select="key('styles-by-name', $style/@style:parent-style-name)"/>
    <xsl:variable name="table-heading" select="contains(translate($style/@style:name, $uppercase, $lowercase), 'table head') and ancestor::table:*"/>
    <xsl:variable name="heading" select="not($table-heading) and (contains(translate($style/@text:style-name, $uppercase, $lowercase), 'head') or contains(translate($parent-style/@style:name, $uppercase, $lowercase), 'head'))"/>
    <xsl:variable name="inner-text" select="normalize-space(.)"/>
    <xsl:if test="$inner-text">
        <xsl:choose>
            <xsl:when test="not($heading) and not($table-heading)">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$heading">
                <xsl:element name="text:h">
                    <xsl:copy>
                        <xsl:apply-templates select="@*"/>
                    </xsl:copy>
                    <xsl:attribute name="text:outline-level">
                        <xsl:choose>
                        </xsl:choose>

                    </xsl:attribute>
                    <xsl:apply-templates select="node()"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$table-heading">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                    [TABLE HEADING DEBUG]
                </xsl:copy>
            </xsl:when>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<xsl:template match="office:meta">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
        <xsl:if test="not(dc:title)">
            <xsl:element name="dc:title">
                <xsl:call-template name="choose-dc-title"/>
            </xsl:element>
        </xsl:if>
    </xsl:copy>
</xsl:template>

<xsl:template match="dc:title">
    <xsl:copy>
        <xsl:call-template name="choose-dc-title"/>
    </xsl:copy>
</xsl:template>

<xsl:template name="choose-dc-title">
    <xsl:choose>
        <xsl:when test="self::dc:title and normalize-space(.)">
            <xsl:value-of select="."/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="title-style" select="//style:style[contains(translate(@style:name, $uppercase, $lowercase), 'title')]"/>
            <xsl:variable name="title-text" select="key('elements-by-style-name', $title-style)"/>
            <xsl:choose>
                <xsl:when test="normalize-space($title-text)"><xsl:value-of select="$title-text"/></xsl:when>
                <xsl:otherwise>(no title)</xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="@*|node()">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
   </xsl:copy>
</xsl:template>

</xsl:stylesheet>
