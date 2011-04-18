<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook" xmlns="docvert:5" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="db html xlink">
<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="yes"/>

<xsl:variable name="alignment" select=" normalize-space('
Table1Heading1:center,
Table1Heading2:center,
Table1Heading3:center,
table1cell1:center,
table1cell2:center,
table1cell3:center,
table1cell4:center,
table1cell5:center,
table1cell6:center,
table1cell7:center,
table1cell8:center,
table1cell9:center,
Table2Heading1:left,
Table2Heading2:left,
Table2Heading3:left,
Table3Heading1:right,
Table3Heading2:right,
Table3Heading3:right,
Table4Heading1:center,
Table4Heading2:center,
Table4Heading3:center,
')"/>

<xsl:template match="/">
    <group>
        <xsl:apply-templates/>
    </group>
</xsl:template>

<xsl:template match="html:td[@class] | html:th[@class]">
    <xsl:variable name="inner-text" select="normalize-space(.)"/>
    <xsl:if test="contains($alignment, concat($inner-text,':'))">
        <xsl:variable name="expected-alignment" select="substring-before(substring-after($alignment, concat($inner-text,':')), ',')"/>
        <xsl:choose>
            <xsl:when test="@class = concat('align-',$expected-alignment)"><pass>Cell with <xsl:value-of select="$inner-text"/> does contain correct alignment of <xsl:value-of select="$expected-alignment"/></pass></xsl:when>
            <xsl:otherwise><fail>Cell with <xsl:value-of select="$inner-text"/> doesn't contain correct alignment of <xsl:value-of select="$expected-alignment"/></fail></xsl:otherwise>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<xsl:template match="text()"/>


</xsl:stylesheet>


