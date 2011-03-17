<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xslo="http://www.w3.org/1999/XSL/TransformAlias">
    <xsl:namespace-alias stylesheet-prefix="xslo" result-prefix="xsl"/>

	<xsl:output method="xml" omit-xml-declaration="no"/>

    <xsl:template match="/">
        <xslo:stylesheet version="1.0">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xslo:stylesheet>
    </xsl:template>

    <xsl:template match="node()|@*">
        <xslo:template match="node()|@*">
            
        <xsl:text disable-output-escaping="True">&lt;xsl:template&gt;</xsl:text>
        <xsl:for-each select="ancestor-or-self::*">
        </xsl:for-each>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
        <xsl:text disable-output-escaping="True">&lt;/xsl:template&gt;</xsl:text>
    </xsl:template>

</xsl:stylesheet>
