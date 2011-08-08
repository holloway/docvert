<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook" xmlns="docvert:5" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="db html xlink">
<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:template match="/">
    <group>
        <xsl:if test="count(//html:ol) != 6">
            <fail>There were not as many lists in continuation.odt as expected. There were <xsl:value-of select="count(//html:ol)"/> lists.</fail>
        </xsl:if>
        <xsl:apply-templates/>
    </group>
</xsl:template>

<xsl:template match="html:ol[count(preceding::html:ol) = 1]">
    <!-- first list -->
    <xsl:choose>
        <xsl:when test="@start = '5' ">
            <pass>List continuation: First list starts counting at 5 as expected.</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>List continuation: First list starts does not start at 5 as was expected.</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="html:ol[count(preceding::html:ol) = 2]">
    <!-- second list -->
    <xsl:choose>
        <xsl:when test="@start = '8' ">
            <pass>List continuation: Second list starts counting at 8 as expected.</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>List continuation: Second list starts does not start at 8 as was expected.</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="html:ol[count(preceding::html:ol) = 3]">
    <!-- third list -->
    <xsl:choose>
        <xsl:when test="@start = '11' ">
            <pass>List continuation: Third list starts counting at 11 as expected.</pass>
        </xsl:when>
        <xsl:otherwise>
            <fail>List continuation: Third list starts does not start at 11 as was expected.</fail>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


<xsl:template match="text()"/>

</xsl:stylesheet>


