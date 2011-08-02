<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:db="http://docbook.org/ns/docbook" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink">
<xsl:output	method="xml" version="1.0" encoding="UTF-8" doctype-public="-//OASIS//DTD DocBook XML V4.1.2//EN" doctype-system="http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd" indent="yes" omit-xml-declaration="no"/>

<xsl:key name="elementById" match="*[@xml:id]" use="@xml:id"/>

<xsl:param name="loopDepth"/>
<xsl:param name="process"/>
<xsl:param name="customFilenameIndex"/>
<xsl:param name="customFilenameSection"/>

<xsl:variable name="detectedDepth">
	<xsl:call-template name="detectDepth"/>
</xsl:variable>

<xsl:template match="/db:book">
	<xsl:copy>
		<xsl:apply-templates select="db:title"/>
		<xsl:apply-templates select="db:abstract"/>
		<xsl:apply-templates select="db:toc"/>
		<xsl:apply-templates select="db:info"/>
		<xsl:if test="//db:chapter">
			<xsl:choose>
				<xsl:when test="$detectedDepth = 'ByChapters' ">
					<xsl:call-template name="break-at-chapter--inline-table-of-contents"/>
					<xsl:call-template name="break-at-chapter--menu"/>
					<xsl:call-template name="break-at-chapter--internal"/>
				</xsl:when>
				<xsl:when test="$detectedDepth = 'BySect1s'">
					<xsl:call-template name="break-at-sect1s--toc"/>
					<xsl:call-template name="break-at-chapter--internal"/>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="$process = 'GetPreface' ">
				<xsl:choose>
					<xsl:when test="$detectedDepth = 'ByChapters' ">
						<xsl:apply-templates select="db:preface"/>
					</xsl:when>
					<xsl:when test="$detectedDepth = 'BySect1s' ">
						<xsl:apply-templates select="db:chapter[position() = $loopDepth]/db:sect1[position() = 1]/preceding-sibling::*"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes">
							$detectedDepth of "<xsl:value-of select="$detectedDepth"/>" isn't supported.
						</xsl:message>					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$process = 'SplitPages' ">
				<xsl:choose>
					<xsl:when test="$detectedDepth = 'ByChapters' ">
						<xsl:apply-templates select="db:chapter[position() = $loopDepth]"/>
					</xsl:when>
					<xsl:when test="$detectedDepth = 'BySect1s' ">
						<xsl:variable name="chapterIndex" select="substring-before($loopDepth, '-')"/>
						<xsl:variable name="sect1Index" select="substring-after($loopDepth, '-')"/>
						<xsl:apply-templates select="db:chapter[position() = $chapterIndex]/db:sect1[position() = $sect1Index]"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message terminate="yes">
							detectedDepth of "<xsl:value-of select="$detectedDepth"/>" isn't supported.
						</xsl:message>					
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				$process = "<xsl:value-of select="$process"/>" which is invalid. Valid options are "SplitPages" and "GetPreface".
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="//db:chapter">
			<xsl:choose>
				<xsl:when test="$detectedDepth = 'ByChapters' ">
					<xsl:call-template name="break-at-chapter--next-previous-menu"/>
				</xsl:when>
				<xsl:when test="$detectedDepth = 'BySect1s'">
					<xsl:call-template name="break-at-sect1s--next-previous-menu"/>
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:copy>
</xsl:template>

<xsl:template name="detectDepth">
	<xsl:variable name="withoutHyphens"><xsl:value-of select="translate($loopDepth,'-','')"/></xsl:variable>
	<xsl:variable name="differenceInLength"><xsl:value-of select="string-length($loopDepth) - string-length($withoutHyphens)"/></xsl:variable>
	<xsl:choose>
		<xsl:when test="$differenceInLength = 0">ByChapters</xsl:when>
		<xsl:when test="$differenceInLength = 1">BySect1s</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="yes">
				Breaking up over other than 1st or 2nd level headings hasn't yet been written.
				You can add it yourself to "each.page.xsl".
			</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="break-at-chapter--inline-table-of-contents">
	<db:toc>
		<xsl:if test="db:title">
			<db:tocentry><db:link xlink:href="{$customFilenameIndex}"><xsl:value-of select="db:title"/></db:link></db:tocentry>
		</xsl:if>
		<xsl:apply-templates mode="tableOfContents">
			<xsl:with-param name="breakAt" select=" 'chapter' "/>
		</xsl:apply-templates>
	</db:toc>
</xsl:template>

<xsl:template match="db:preface | db:chapter | db:sect1 | db:sect2 | db:sect3 | db:sect4 | db:sect5 | db:sect6 | db:sect7 | db:sect8 | db:sect9" mode="tableOfContents">
	<xsl:param name="breakAt"/>
	<xsl:variable name="url">
		<xsl:choose>
			<xsl:when test="$breakAt = 'chapter' ">
				<xsl:variable name="chapterIndex" select=" count(preceding::db:chapter | preceding::db:preface) "/>
				<xsl:choose>
					<xsl:when test="self::db:preface">
						<xsl:value-of select="$customFilenameIndex"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="search-and-replace">
							<xsl:with-param name="input" select="$customFilenameSection"/>
							<xsl:with-param name="search-string" select=" '#' "/>
							<xsl:with-param name="replace-string" select=" $chapterIndex "/>
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
		<xsl:text>#title</xsl:text>
		<xsl:value-of select="count(preceding::db:title) + 1"/>
	</xsl:variable>
	<db:tocentry>
		<db:link xlink:href="{$url}">
			<xsl:value-of select="db:title[1]"/>
		</db:link>
		<xsl:if test="descendant::db:preface or descendant::db:chapter or descendant::db:sect1 or descendant::db:sect2 or descendant::db:sect3 or descendant::db:sect4 or descendant::db:sect5 or descendant::db:sect6 or descendant::db:sect7 or descendant::db:sect8 or descendant::db:sect9 ">
			<db:tocchap>
				<xsl:apply-templates mode="tableOfContents">
					<xsl:with-param name="breakAt" select=" $breakAt "/>
				</xsl:apply-templates>
			</db:tocchap>
		</xsl:if>
	</db:tocentry>
</xsl:template>

<xsl:template match="text()" mode="tableOfContents"/>

<xsl:template name="break-at-chapter--next-previous-menu">
	<!-- Menu: Next Previous -->
	<xsl:variable name="previousSection">
		<xsl:choose>
			<xsl:when test="$loopDepth = 1"><xsl:value-of select="$customFilenameIndex"/></xsl:when>
			<xsl:when test="$loopDepth &gt; 1">
				<xsl:call-template name="search-and-replace">
					<xsl:with-param name="input" select="$customFilenameSection"/>
					<xsl:with-param name="search-string" select=" '#' "/>
					<xsl:with-param name="replace-string" select="number($loopDepth) - 1"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="nextSection">
		<xsl:choose>
			<xsl:when test="$loopDepth = count(/db:book/db:chapter)"></xsl:when>
			<xsl:when test="$loopDepth = '' ">
				<xsl:call-template name="search-and-replace">
					<xsl:with-param name="input" select="$customFilenameSection"/>
					<xsl:with-param name="search-string" select=" '#' "/>
					<xsl:with-param name="replace-string" select=" '1' "/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="search-and-replace">
					<xsl:with-param name="input" select="$customFilenameSection"/>
					<xsl:with-param name="search-string" select=" '#' "/>
					<xsl:with-param name="replace-string" select="number($loopDepth) + 1"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<db:GUIMenu id="nextPreviousMenu">
		<xsl:if test="normalize-space($previousSection)">
			<db:GUISubMenu>
				<db:link xlink:href="{$previousSection}" role="prev">Previous</db:link>
			</db:GUISubMenu>
		</xsl:if>
		<xsl:if test="$loopDepth != 0 and $loopDepth != '' ">
			<db:GUISubMenu>
				<db:link xlink:href="{$customFilenameIndex}" role="start">Index</db:link>
			</db:GUISubMenu>
		</xsl:if>
		<xsl:if test="normalize-space($nextSection)">
			<db:GUISubMenu>
				<db:link xlink:href="{$nextSection}" role="next">Next</db:link>
			</db:GUISubMenu>
		</xsl:if>
	</db:GUIMenu>
</xsl:template>

<xsl:template name="break-at-chapter--menu">
	<!-- Menu: All Pages -->
	<db:GUIMenu id="pagesMenu">
		<db:GUISubMenu>
			<db:link xlink:href="{$customFilenameIndex}">
				<xsl:choose>
					<xsl:when test="/db:book/db:info/db:title"><xsl:value-of select="/db:book/db:info/db:title"/></xsl:when>
					<xsl:otherwise>[no title]</xsl:otherwise>
				</xsl:choose>
			</db:link>
		</db:GUISubMenu>
		<xsl:for-each select="/db:book/db:chapter">
			<db:GUISubMenu>
				<xsl:variable name="sectionIndex" select="position()"/>
				<xsl:variable name="sectionTitle" select="db:title[position() = 1]"/>
				<xsl:variable name="url">
					<xsl:call-template name="search-and-replace">
						<xsl:with-param name="input" select="$customFilenameSection"/>
						<xsl:with-param name="search-string" select=" '#' "/>
						<xsl:with-param name="replace-string" select=" position() "/>
					</xsl:call-template>
				</xsl:variable>
				
				<db:link xlink:href="{$url}">
					<xsl:choose>
						<xsl:when test="normalize-space($sectionTitle)"><xsl:value-of select="$sectionTitle"/></xsl:when>
						<xsl:when test="/db:book/db:info/db:title">Chapter <xsl:value-of select="$sectionIndex"/></xsl:when>
						<xsl:otherwise>[no title]</xsl:otherwise>
					</xsl:choose>
				</db:link>
			</db:GUISubMenu>
		</xsl:for-each>
	</db:GUIMenu>
</xsl:template>

<xsl:template name="break-at-chapter--internal">
	<!-- Menu: Internal to Page. Within this page. -->
	<xsl:choose>
		<xsl:when test="$loopDepth = '' ">
			<!-- a preface... no heading by definition -->
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="pageTitles" select="/db:book/db:chapter[position() = $loopDepth]/db:sect1/db:title[position() = 1]"/>
			<xsl:if test="$pageTitles">
				<db:GUIMenu id="pageInternalMenu">
					<xsl:for-each select="$pageTitles">
						<db:GUISubMenu>
							<db:link>
								<xsl:attribute name="xlink:href">
									<xsl:text>#title</xsl:text>
									<xsl:number level="any"/>
								</xsl:attribute>
								<xsl:apply-templates select="."/>
								<xsl:if test="not(normalize-space(.))">
									[no title]
								</xsl:if>
							</db:link>
						</db:GUISubMenu>
					</xsl:for-each>
				</db:GUIMenu>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="break-at-sect1">
	<xsl:message terminate="yes">
		In-build support for breaking up over Sect1's has been temporarily removed. Please mention this on the mailing list...
	</xsl:message>
</xsl:template>

<xsl:template name="break-at-sect1s--toc">
	<xsl:message terminate="yes">
		In-build support for breaking up over Sect1's has been temporarily removed. Please mention this on the mailing list...
	</xsl:message>
</xsl:template>

<xsl:template name="break-at-sect1s--next-previous-menu">
	<xsl:message terminate="yes">
		In-build support for breaking up over Sect1's has been temporarily removed. Please mention this on the mailing list...
	</xsl:message>
</xsl:template>

<xsl:template match="db:title">
	<xsl:copy>
		<xsl:attribute name="id">
			<xsl:text>title</xsl:text>
			<xsl:number level="any"/>
		</xsl:attribute>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="db:link">
    <xsl:element name="db:link">
        <xsl:attribute name="xlink:href">
            <xsl:choose>
                <xsl:when test="starts-with(@xlink:href, '#')">
                    <xsl:variable name="target" select="key('elementById', substring(@xlink:href, 2))"/>
                    <xsl:if test="$target">
                        <xsl:variable name="section" select="$target/ancestor::*[self::db:preface or self::db:chapter][1]"/>
                        <xsl:if test="$section">
                            <xsl:variable name="sectionIndex" select="count($section/preceding::*[self::db:preface or self::db:chapter])"/>
                            <xsl:choose>
                                <xsl:when test="$sectionIndex = 0">
						            <xsl:value-of select="$customFilenameIndex"/>
                                </xsl:when>
                                <xsl:otherwise>
						            <xsl:call-template name="search-and-replace">
							            <xsl:with-param name="input" select="$customFilenameSection"/>
							            <xsl:with-param name="search-string" select=" '#' "/>
							            <xsl:with-param name="replace-string" select=" $sectionIndex "/>
						            </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:if>
                    <xsl:value-of select="@xlink:href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@xlink:href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>

<xsl:template match="@*|node()">
	<xsl:copy>
		<xsl:apply-templates select="@*|node()"/>
	</xsl:copy>
</xsl:template>

<xsl:template name="search-and-replace">
	<xsl:param name="input"/>
	<xsl:param name="search-string"/>
	<xsl:param name="replace-string"/>
	<xsl:choose>
		<xsl:when test="$search-string and contains($input, $search-string)">
			<xsl:value-of select="substring-before($input, $search-string)"/>
			<xsl:value-of select="$replace-string"/>
			<xsl:call-template name="search-and-replace">
				<xsl:with-param name="input" select="substring-after($input,$search-string)"/>
				<xsl:with-param name="search-string" select="$search-string"/>
				<xsl:with-param name="replace-string" select="$replace-string"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$input"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:stylesheet>

