<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook" xmlns="docvert:5" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="db html xlink">
<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:template match="/">
    <group>
        <xsl:if test="count(//html:em) != 2">
            <fail>There were not as many emphasis tags as expected. There were <xsl:value-of select="count(//html:em)"/> em tags.</fail>
        </xsl:if>
        <xsl:if test="count(//html:strong) != 2">
            <fail>There were not as many strong tags as expected. There were <xsl:value-of select="count(//html:strong)"/> strong tags.</fail>
        </xsl:if>

        <xsl:apply-templates/>
    </group>
</xsl:template>

<xsl:template match="html:em[count(preceding::html:em) = 0]">
    <!-- first em -->
    <xsl:choose>
        <xsl:when test="normalize-space(.) = 'inline italics' ">
            <pass>Emphasis: First em contains 'inline italics' as expected. Contained "<xsl:value-of select="normalize-space(.)"/>"</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>Emphasis: First em does not contain 'inline italics' as expected. Contained "<xsl:value-of select="normalize-space(.)"/>"</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="html:em[count(preceding::html:em) = 1]">
    <!-- second em -->
    <xsl:choose>
        <xsl:when test="normalize-space(.) = 'inline-bold and italics' ">
            <pass>Emphasis: Second em contains 'inline-bold and italics' as expected. Contained "<xsl:value-of select="normalize-space(.)"/>"</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>Emphasis: Second em does not contain 'inline-bold and italics' as expected. Contained "<xsl:value-of select="normalize-space(.)"/>"</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="html:strong[count(preceding::html:strong) = 0]">
    <!-- first strong -->
    <xsl:choose>
        <xsl:when test="normalize-space(.) = 'inline bold' ">
            <pass>Strong: First strong contains 'inline bold' as expected. Contained "<xsl:value-of select="normalize-space(.)"/>"</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>Strong: First strong does not contain 'inline bold' as expected. Contained "<xsl:value-of select="normalize-space(.)"/>"</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="html:strong[count(preceding::html:strong) = 1]">
    <!-- second strong -->
    <xsl:choose>
        <xsl:when test="normalize-space(.) = 'inline-bold and italics' ">
            <pass>Strong: Second strong contains 'inline-bold and italics' as expected. Contained "<xsl:value-of select="normalize-space(.)"/>"</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>Strong: Second strong does not contain 'inline-bold and italics' as expected. Contained "<xsl:value-of select="normalize-space(.)"/>"</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>


