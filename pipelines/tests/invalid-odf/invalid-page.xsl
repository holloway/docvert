<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="docvert:5" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0">
<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:template match="/">
    <group>
        <xsl:apply-templates/>
    </group>
</xsl:template>

<xsl:template match="draw:frame">
     <xsl:choose>
        <xsl:when test="@text:anchor-page-number='0'">
            <fail>A &lt;draw:frame&gt; shouldn't have a page number of zero.</fail>
        </xsl:when>
        <xsl:otherwise>
            <pass>A &lt;draw:frame&gt; had a valid anchoring.</pass>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="text()"/>

</xsl:stylesheet>


