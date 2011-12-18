<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook">
<xsl:output method="xml" omit-xml-declaration="no"/>

<xsl:template match="db:orderedlist">
   <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:if test="ancestor::db:orderedlist[1][@continuation][db:listitem/*[not(self::db:orderedlist[@continuation])]]">
            <xsl:attribute name="continuation">
                <xsl:text>continues</xsl:text>
            </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="node()"/>
   </xsl:copy>
</xsl:template>

<xsl:template match="@*|node()">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
   </xsl:copy>
</xsl:template>

</xsl:stylesheet>
