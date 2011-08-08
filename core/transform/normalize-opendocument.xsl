<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0">
<xsl:output method="xml" omit-xml-declaration="no"/>

<xsl:key name="styles-by-name" match="style:style" use="@style:name"/>
<xsl:key name="list-styles-by-name" match="text:list-style" use="@style:name"/>
<xsl:key name="elements-by-style-name" match="*[@text:style-name]" use="@text:style-name"/>

<xsl:variable name="lowercase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
<xsl:variable name="uppercase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
<xsl:variable name="remove-when-normalizing">_- 01234567890</xsl:variable><!-- space character is intentional -->
<xsl:variable name="remove-for-outline-level" select="concat($uppercase,$lowercase,'_- ')"/><!-- space character is intentional -->

<!-- these variables are | separated lists of normalized (as per above) style names AND ending with a | character -->
<xsl:variable name="table-heading-styles">tableheading|tableheader|titredetableau|titretableau|</xsl:variable>
<xsl:variable name="document-title-styles">title|titre|</xsl:variable>
<xsl:variable name="heading-styles">heading|header|</xsl:variable>
<xsl:variable name="bulleted-list-styles">bullet|</xsl:variable>


<xsl:template match="text:p">
    <xsl:variable name="style" select="key('styles-by-name', @text:style-name)"/>
    <xsl:variable name="normalized-style-name" select="translate(translate($style/@style:name, $uppercase, $lowercase),$remove-when-normalizing,'')"/>
    <xsl:variable name="parent-style" select="key('styles-by-name', $style/@style:parent-style-name)"/>
    <xsl:variable name="normalized-parent-style-name" select="translate(translate($parent-style/@style:name, $uppercase, $lowercase),$remove-when-normalizing,'')"/>
    <xsl:variable name="table-heading" select="ancestor::table:* and (
        (contains($table-heading-styles, concat($normalized-style-name,'|')) and normalize-space($normalized-style-name)) or
        (contains($table-heading-styles, concat($normalized-parent-style-name,'|')) and normalize-space($normalized-parent-style-name)) )"/>
    <xsl:variable name="document-title" select="not($table-heading) and (
        (contains(document-title-styles, concat($normalized-style-name,'|')) and normalize-space($normalized-style-name)) or
        (contains(document-title-styles, concat($normalized-parent-style-name,'|')) and normalize-space($normalized-parent-style-name)) )"/>
    <xsl:variable name="heading" select="not($table-heading) and not($document-title) and (
        (contains($heading-styles, concat($normalized-style-name,'|')) and normalize-space($normalized-style-name)) or
        (contains($heading-styles, concat($normalized-parent-style-name,'|')) and normalize-space($normalized-parent-style-name)) )"/>
    <xsl:variable name="heading-outline-level">
        <xsl:if test="$heading">
            <xsl:variable name="heading-style">
                <xsl:choose>
                    <xsl:when test="contains($heading-styles, concat($normalized-style-name,'|'))">
                        <xsl:value-of select="$style"/>
                    </xsl:when>
                    <xsl:when test="contains($heading-styles, concat($normalized-parent-style-name,'|'))">
                        <xsl:value-of select="$parent-style"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="decoded-heading-style">
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="subject" select="$heading-style"/>
                    <xsl:with-param name="search" select="'_20_'"/>
                    <xsl:with-param name="replace" select="' '"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="parsed-outline-level" select="number(normalize-space(translate($decoded-heading-style,$remove-for-outline-level,'')))"/>
            <xsl:choose>
                <xsl:when test="string($parsed-outline-level) != 'NaN'">
                    <xsl:value-of select="$parsed-outline-level"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>1</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:variable>
    <xsl:variable name="inner-text" select="normalize-space(.)"/>
    <xsl:if test="$inner-text or descendant::draw:frame/draw:image">
        <xsl:choose>
            <xsl:when test="not($table-heading) and not($document-title) and not($heading)">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$table-heading">
                <xsl:copy>
                    <xsl:apply-templates select="@*"/>
                    <xsl:attribute name="text:class-names">table-heading</xsl:attribute>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$document-title">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:when test="$heading">
                <xsl:element name="text:h">
                    <xsl:attribute name="text:outline-level"><xsl:value-of select="$heading-outline-level"/></xsl:attribute>
                    <xsl:attribute name="text:style-name"><xsl:value-of select="@text:style-name"/></xsl:attribute>
                    [<xsl:apply-templates/>
                    <!--[{<xsl:value-of select="@text:style-name"/>}<xsl:value-of select="$style/@style:name"/>:<xsl:value-of select="$normalized-style-name"/> | <xsl:value-of select="$normalized-parent-style-name"/>]-->
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:if>
</xsl:template>

<xsl:template match="text:h">
    <xsl:choose>
        <xsl:when test="ancestor::table:table">
            <xsl:element name="text:p">
                <xsl:copy-of select="@*"/>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="text:list">
    <xsl:variable name="list-style">
        <xsl:choose>
            <xsl:when test="@text:style-name"><xsl:value-of select="@text:style-name"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="ancestor::text:list[@text:style-name]/@text:style-name"/></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="style" select="key('list-styles-by-name', $list-style)"/>
    <xsl:variable name="normalized-style-name" select="translate(translate($style/@style:name, $uppercase, $lowercase),$remove-when-normalizing,'')"/>
    <xsl:variable name="parent-style" select="key('list-styles-by-name', $style/@style:parent-style-name)"/>
    <xsl:variable name="normalized-parent-style-name" select="translate(translate($parent-style/@style:name, $uppercase, $lowercase),$remove-when-normalizing,'')"/>
    <xsl:variable name="list-depth" select="count(ancestor::text:list-item) + 1"/>
    <xsl:choose>
        <xsl:when test="$style/text:list-level-style-number[@text:level=$list-depth] or $parent-style/text:list-level-style-number[@text:level=$list-depth]">
            <xsl:element name="text:ordered-list">
                <xsl:if test="normalize-space($list-style)"><xsl:attribute name="text:style-name"><xsl:value-of select="$list-style"/></xsl:attribute></xsl:if>
                <xsl:if test="@text:continue-numbering"><xsl:attribute name="text:continue-numbering"><xsl:value-of select="@text:continue-numbering"/></xsl:attribute></xsl:if>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:when>
        <xsl:otherwise>
            <xsl:element name="text:unordered-list">
                <xsl:if test="normalize-space($list-style)"><xsl:attribute name="text:style-name"><xsl:value-of select="$list-style"/></xsl:attribute></xsl:if>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="office:meta">
    <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
        <xsl:if test="not(dc:title)">
            <xsl:element name="dc:title">
                <xsl:call-template name="choose-dc-title"/>
            </xsl:element>
        </xsl:if>
    </xsl:copy>
</xsl:template>

<xsl:template match="dc:title">
    <xsl:copy>
        <xsl:call-template name="choose-dc-title"/>
    </xsl:copy>
</xsl:template>

<xsl:template name="choose-dc-title">
    <xsl:choose>
        <xsl:when test="self::dc:title and normalize-space(.)">
            <xsl:value-of select="."/>
        </xsl:when>
        <xsl:otherwise>
            <xsl:variable name="style" select="key('styles-by-name', @text:style-name)"/>
            <xsl:variable name="normalized-style" select="translate(translate($style, $uppercase, $lowercase),$remove-when-normalizing,'')"/>
            <xsl:variable name="parent-style" select="key('styles-by-name', $style/@style:parent-style-name)"/>
            <xsl:variable name="normalized-parent-style" select="translate(translate(parent-style, $uppercase, $lowercase),$remove-when-normalizing,'')"/>
            <xsl:variable name="title-style" select="//style:style[contains($document-title-styles, concat(translate(translate(@style:name, $uppercase, $lowercase),$remove-when-normalizing,''),'|'))]"/>
            <xsl:variable name="title-text" select="key('elements-by-style-name', $title-style)"/>
            <xsl:choose>
                <xsl:when test="normalize-space($title-text)"><xsl:value-of select="$title-text"/></xsl:when>
                <xsl:otherwise>(no title)</xsl:otherwise>
            </xsl:choose>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="text:section">
    <xsl:apply-templates/>
</xsl:template>

<xsl:template match="@*|node()">
   <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
   </xsl:copy>
</xsl:template>

<xsl:template name="replace-string">
    <xsl:param name="subject"/>
    <xsl:param name="search"/>
    <xsl:param name="replace"/>
    <xsl:choose>
        <xsl:when test="contains($subject,$search)">
            <xsl:value-of select="concat(substring-before($subject,$search),$replace)"/>
            <xsl:call-template name="replace-string">
                <xsl:with-param name="subject" select="substring-after($subject,$search)"/>
                <xsl:with-param name="search" select="$search"/>
                <xsl:with-param name="replace" select="$replace"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$subject"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
