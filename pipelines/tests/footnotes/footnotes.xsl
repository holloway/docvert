<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook" xmlns="docvert:5" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="db html xlink">
<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:template match="/">
    <group>
        <xsl:if test="count(//db:footnote) != 2">
            <fail>There were not as many footnote tags as expected. There were <xsl:value-of select="count(//db:footnote)"/> footnote tags.</fail>
        </xsl:if>
        <xsl:apply-templates/>
    </group>
</xsl:template>

<xsl:template match="db:footnote[count(preceding::db:footnote) = 0]">
    <!-- first footnote -->
    <xsl:choose>
        <xsl:when test="@label = '1' and count(db:para) = 1 and normalize-space(db:para) = 'March 3, 2006; Page A10' ">
            <pass>First footnote correctly formatted.</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>First footnote incorrectly formatted.</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="db:footnote[count(preceding::db:footnote) = 1]">
    <!-- second footnote -->
    <xsl:choose>
        <xsl:when test="@label = '2' and count(db:para) = 1 and normalize-space(db:para) = 'Microsoft Word-processing documents'">
            <pass>Second footnote correctly formatted.</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>Second footnote incorrectly formatted.</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>


