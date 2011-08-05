<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook" xmlns="docvert:5" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="db html xlink">
<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:template match="/">
    <group>
        <xsl:apply-templates/>
    </group>
</xsl:template>

<xsl:template match="html:a[@href and starts-with(@href, '#')]">
    <xsl:variable name="target" select="substring(@href, 2)"/>
    <xsl:choose>
        <xsl:when test="//*[@id=$target]">
            <pass>Link has source:target of "<xsl:value-of select="$target"/>"</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>Link target of "<xsl:value-of select="$target"/>" doesn't exist</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="html:a[@id]">
    <xsl:variable name="target" select="@id"/>
    <xsl:choose>
        <xsl:when test="//html:a[@href=concat('#', $target)]">
            <pass>Link has source:target of "<xsl:value-of select="$target"/>"</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>Link source of "<xsl:value-of select="$target"/>" doesn't exist</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>


