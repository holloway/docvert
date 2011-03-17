<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="docvert:5">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <group>
            <xsl:choose>
                <xsl:when test="//text()[contains(., 'It seems to me that this is one of those times')]">
                    <pass>Document contains text node ("It seems to me that this is one of those times").</pass>
                </xsl:when>
                <xsl:otherwise>
                    <fail>Document does not contain string ("It seems to me that this is one of those times").</fail>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="//text()[contains(., 'option 5')]">
                    <pass>Document contains text node ("option 5").</pass>
                </xsl:when>
                <xsl:otherwise>
                    <fail>Document does not contain text node ("option 5").</fail>
                </xsl:otherwise>
            </xsl:choose>
        </group>
    </xsl:template>

</xsl:stylesheet>
