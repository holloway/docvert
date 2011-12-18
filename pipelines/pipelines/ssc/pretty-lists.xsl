<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="db html xlink"
	>

	<xsl:output
		method="xml"
		version="1.0"
		encoding="UTF-8"
		indent="yes"
		doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
		doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
		omit-xml-declaration="yes"/>

    <xsl:template match="html:ol">
        <xsl:element name="ol">
            <xsl:attribute name="class">
                <xsl:text>custom-order</xsl:text>
                <xsl:if test="@role='NestedOrderedList'">
                    <xsl:text> NestedOrderedList</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="ancestor::html:ol">
                    <xsl:attribute name="style">
                        <xsl:variable name="depth" select="1 + count(ancestor::html:ol)"/>
                        <xsl:text>list-style:none;padding-left:</xsl:text>
                        <xsl:choose>
                            <xsl:when test="$depth = 1">
                                <xsl:text>2</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$depth * 1.3"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>em;</xsl:text>
                        <xsl:value-of select="@style"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="@style">
                    <xsl:attribute name="style">
                        <xsl:value-of select="@style"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:if test="@start">
              <xsl:attribute name="start"><xsl:value-of select="@start"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="html:li[parent::html:ol]">
        <xsl:variable name="depth" select="count(ancestor::html:li)+1"/>
        <xsl:variable name="offset">
            <xsl:choose>
                <xsl:when test="$depth = 1">
                    <xsl:text>2</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$depth * 1.3"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="width" select="$offset"/>
        <xsl:element name="li">
            <xsl:attribute name="style">list-style:none</xsl:attribute>
            <xsl:if test="*[not(self::html:ol)]">
                <xsl:element name="span">
	                <xsl:attribute name="class">NestedOrderedListNumbering</xsl:attribute>
                    <xsl:attribute name="style">float:left;width:<xsl:value-of select="$width"/>em;margin-left:-<xsl:value-of select="$offset"/>em;</xsl:attribute>
                    <xsl:for-each select="ancestor::html:ol">
                        <xsl:choose>
                            <xsl:when test="@start"><xsl:value-of select="@start"/></xsl:when>
                            <xsl:otherwise><xsl:value-of select="count(preceding-sibling::html:ol)+1"/></xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="position() &lt; last()">
                            <xsl:text>.</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
