<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:db="http://docbook.org/ns/docbook" xmlns:docvert="docvert:5" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0">
    <xsl:output method="xml" omit-xml-declaration="no"/>

    <!-- <xsl:key name='heading-children' match="*[not(self::text:h or self::text:section)]" use="generate-id((..|preceding-sibling::text:h[@text:outline-level='1']|preceding-sibling::text:h[@text:outline-level='2']|preceding-sibling::text:h[@text:outline-level='3']|preceding-sibling::text:h[@text:outline-level='4']|preceding-sibling::text:h[@text:outline-level='5']|preceding-sibling::text:h[@text:outline-level='6'])[last()])"/> -->
    <xsl:key name='heading-children' match="text:p | table:table | text:ordered-list | text:list | draw:frame | draw:image | svg:desc | office:annotation | text:unordered-list | text:footnote | text:a | text:list-item | draw:plugin | draw:text-box | text:footnote-body | text:section" use="generate-id((..|preceding-sibling::text:h[@text:outline-level='1']|preceding-sibling::text:h[@text:outline-level='2']|preceding-sibling::text:h[@text:outline-level='3']|preceding-sibling::text:h[@text:outline-level='4']|preceding-sibling::text:h[@text:outline-level='5']|preceding-sibling::text:h[@text:outline-level='6'])[last()])"/>
    <xsl:key name="list-group" match="text:ordered-list[not(ancestor::text:list-item)] | text:unordered-list[not(ancestor::text:list-item)]" use="concat(generate-id(preceding-sibling::*[not(self::text:unordered-list | self::text:ordered-list)][1]), generate-id(ancestor::table:table-cell))"/>
    <xsl:key name="list-item-group" match="text:list-item[*[not(self::text:unordered-list | self::text:ordered-list)]]" use="concat(generate-id(ancestor::table:table-cell), generate-id(ancestor::*[self::text:unordered-list | self::text:ordered-list][last()]/preceding-sibling::*[not(self::text:unordered-list | self::text:ordered-list)][1]), local-name(parent::*), count(ancestor-or-self::text:list-item))"/>
    <xsl:key name="styles-by-name" match="style:style" use="@style:name"/>
    <xsl:key name="elements-by-style-name" match="*[@text:style-name]" use="@text:style-name"/>
    <xsl:variable name="lowercase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
    <xsl:variable name="uppercase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>

    <xsl:template match="/docvert:root">
        <xsl:apply-templates select="docvert:external-file[@docvert:name='content.xml']"/>
    </xsl:template>

    <xsl:template match="office:text">
        <xsl:element name="db:book">
            <xsl:attribute name="version">5.0</xsl:attribute>
            <xsl:element name="db:preface">
                <xsl:apply-templates select="key('heading-children', generate-id())"/>
                <xsl:if test="not(//text:h[@text:outline-level='1'])"><xsl:apply-templates select="//text:h"/></xsl:if>
            </xsl:element>
            <xsl:apply-templates select="text:h[@text:outline-level='1']"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text:h[@text:outline-level='1']">
        <xsl:call-template name="section">
            <xsl:with-param name="outline-level" select="@text:outline-level"/>
            <xsl:with-param name="previous-outline-level" select="1"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="text:h">
        <xsl:variable name="outline-level" select="@text:outline-level"/>
        <xsl:call-template name="section">
            <xsl:with-param name="outline-level" select="$outline-level"/>
            <xsl:with-param name="previous-outline-level" select="preceding-sibling::text:h[@text:outline-level &lt; $outline-level][1]/@text:outline-level"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="section">
        <xsl:param name="outline-level"/>
        <xsl:param name="previous-outline-level"/>
        <xsl:choose>
            <xsl:when test="$outline-level &gt; $previous-outline-level + 1">
                <xsl:call-template name="draw-section-level">
                    <xsl:with-param name="descend-sections-or-apply-templates" select="'descend-sections'"/>
                    <xsl:with-param name="outline-level" select="$outline-level"/>
                    <xsl:with-param name="previous-outline-level" select="$previous-outline-level"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="draw-section-level">
                    <xsl:with-param name="descend-sections-or-apply-templates" select="'apply-templates'"/>
                    <xsl:with-param name="outline-level" select="$outline-level"/>
                    <xsl:with-param name="previous-outline-level" select="$previous-outline-level"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text:p">
        <xsl:if test="normalize-space(.) or descendant::draw:frame">
            <xsl:element name="db:para">
                <xsl:variable name="text-style" select="key('styles-by-name', @text:style-name)"/>
                <xsl:choose>
                    <xsl:when test="contains($text-style/style:text-properties/@fo:font-style, 'italic')">
                        <xsl:element name="db:emphasis">
                            <xsl:apply-templates/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text:ordered-list">
        <xsl:variable name="separate-list"><xsl:call-template name="is-separate-list"/></xsl:variable>
        <xsl:if test="normalize-space($separate-list)">
            <xsl:element name="db:orderedlist">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text:unordered-list">
        <xsl:variable name="separate-list"><xsl:call-template name="is-separate-list"/></xsl:variable>
        <xsl:if test="normalize-space($separate-list)">
            <xsl:element name="db:itemizedlist">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text:ordered-list" mode="joined-list">
        <xsl:element name="db:orderedlist">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text:unordered-list" mode="joined-list">
        <xsl:element name="db:itemizedlist">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text:list">
        <xsl:message terminate="yes">ERROR: found an ambiguous list, &lt;text:list&gt;, which should have been filtered out by "normalize-opendocument.xsl".</xsl:message>
    </xsl:template>

    <xsl:template name="is-separate-list">
        <xsl:if test="not(preceding-sibling::*[1][self::text:unordered-list or self::text:ordered-list])">
            <xsl:text>is a separate list</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text:list-item">
        <xsl:variable name="list-item-generate-id" select="generate-id()"/>
        <xsl:variable name="ancestor-lists" select="ancestor::*[self::text:unordered-list or self::text:ordered-list]"/>
        <xsl:variable name="ancestor-list" select="$ancestor-lists[1]"/>
        <xsl:variable name="ancestor-list-generate-id" select="generate-id($ancestor-list)"/>
        <xsl:variable name="preceding-non-list" select="$ancestor-list/preceding-sibling::*[not(self::text:unordered-list) and not(self::text:ordered-list)][1]"/>
        <xsl:variable name="list-group" select="key('list-group', concat(generate-id($preceding-non-list), generate-id(ancestor::table:table-cell)))"/>
        <xsl:variable name="current-list-group-position">
            <xsl:for-each select="$list-group">
                <xsl:if test="generate-id() = $ancestor-list-generate-id">
                    <xsl:value-of select="position()"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="not(normalize-space($current-list-group-position))">
            <xsl:message terminate="yes">ERROR: Unable to identify this list within a key(list-group).</xsl:message>
        </xsl:if>
        <xsl:variable name="following-lists-within-group" select="$list-group[position() &gt; $current-list-group-position]"/>
        <xsl:variable name="list-depth" select="count(ancestor-or-self::text:list-item)"/>
        <xsl:variable name="last-list-item-within-ancestor-list" select="$ancestor-list/descendant::text:list-item[last()]"/>
        <xsl:element name="db:listitem">
            <xsl:apply-templates/>
            <xsl:if test="$list-item-generate-id = generate-id($last-list-item-within-ancestor-list)">
<!--                LAST: Current List Group Position: <xsl:value-of select="$current-list-group-position"/> out of <xsl:value-of select="count($list-group)"/>.-->
                <xsl:variable name="list-pointer" select="$following-lists-within-group[1]/descendant::*[self::text:unordered-list or self::text:ordered-list][count(ancestor::text:list-item) &gt;= $list-depth]"/>
                <xsl:choose>
                    <xsl:when test="$list-pointer">
   				    	<xsl:apply-templates select="$list-pointer" mode="joined-list"/>
                    </xsl:when>
                    <xsl:otherwise>
                    
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:element>
        <xsl:if test="$list-item-generate-id = generate-id($last-list-item-within-ancestor-list)">
            <!-- See if there's a continuation of list-items in a list directly down at the same level. Obviously, to continue list numbering the list must be the same $list-type (ordered or unordered). -->
            <xsl:variable name="list-type" select="local-name(parent::*)"/>
            <xsl:variable name="list-item-group" select="key('list-item-group', concat(generate-id(ancestor::table:table-cell),generate-id($preceding-non-list), $list-type, $list-depth) ) " />
            <xsl:variable name="current-list-item-group-position">
                <xsl:for-each select="$list-item-group">
                    <xsl:if test="generate-id() = $list-item-generate-id">
                        <xsl:value-of select="position()"/>
                    </xsl:if>
                </xsl:for-each>
            </xsl:variable>
            <xsl:if test="not(normalize-space($current-list-item-group-position))">
                <xsl:message terminate="yes">ERROR: Unable to identify this list-item within a key(list-item-group).</xsl:message>
            </xsl:if>
            <xsl:apply-templates select="$list-item-group[position() &gt; $current-list-item-group-position]"/>
        </xsl:if>
    </xsl:template>

<!--
<xsl:template match="text:list-item">
	<xsl:variable name="ancestorLists" select="ancestor::*[self::text:unordered-list or self::text:list or self::text:ordered-list]"/>
	<xsl:variable name="ancestorList" select="$ancestorLists[position() = 1]"/>
	<xsl:variable name="ancestorListGenerateId" select="generate-id($ancestorList)"/>

	<xsl:variable name="precedingNonList" select="$ancestorList/preceding-sibling::*[not(self::text:unordered-list) and not(self::text:list) and not(self::text:ordered-list)][1]"/>
	<xsl:variable name="allLists" select="key('list-group', generate-id($precedingNonList))"/>
	<xsl:variable name="currentListIndex">
		<xsl:for-each select="$allLists">
			<xsl:if test="generate-id() = $ancestorListGenerateId">
				<xsl:value-of select="position()"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="followingLists" select="$allLists[position() &gt; number($currentListIndex)]"/>
	<xsl:variable name="currentListItemDepth" select="count(ancestor-or-self::text:list-item)"/>
	<xsl:variable name="lastListItemWithinAncestorList" select="$ancestorList/descendant::text:list-item[position() = last()]"/>

	<xsl:element name="db:listitem">
		<xsl:if test="not(normalize-space($currentListIndex))">
			Error, unable to determine list
			((<xsl:value-of select="count($followingLists)"/>/<xsl:value-of select="count($allLists)"/>:<xsl:value-of select="$currentListIndex"/>))
		</xsl:if>

		<xsl:apply-templates/>
		<xsl:if test="generate-id() = generate-id($lastListItemWithinAncestorList)">


            <xsl:variable name="listPointer" select="parent::*/following-sibling::*[self::text:unordered-list or self::text:list or self::text:ordered-list]"/>
            <xsl:choose>
                <xsl:when test="parent::*[self::text:unordered-list or self::text:list or self::text:ordered-list][position()=last()]/following-sibling::*[1][self::text:unordered-list or self::text:list or self::text:ordered-list]">
   					<xsl:apply-templates select="$listPointer[1]" mode="listPullBack"/>

                </xsl:when>
                <xsl:otherwise>
                    
                </xsl:otherwise>
            </xsl:choose>
		</xsl:if>
	</xsl:element>
	<xsl:if test="generate-id() = generate-id($lastListItemWithinAncestorList)">
       <xsl:choose>
            <xsl:when test="ancestor::*[self::text:unordered-list or self::text:list or self::text:ordered-list][position()=last()]/following-sibling::*[self::text:unordered-list or self::text:list or self::text:ordered-list]">
                <xsl:variable name="styleName" select="parent::*/@text:style-name"/>
		        <xsl:variable name="listItemPointer" select="$followingLists/descendant::text:list-item[count(ancestor::text:list-item) = $currentListItemDepth - 1 and *[not(self::text:unordered-list or self::text:list or self::text:ordered-list)] and @text:style-name=$styleName]"/>
		        <xsl:if test="$listItemPointer">
			       <xsl:apply-templates select="$listItemPointer"/>
		        </xsl:if>
				</xsl:when>
            <xsl:otherwise>

            </xsl:otherwise>
	    </xsl:choose>
      </xsl:if>
</xsl:template>
-->


    <xsl:template match="text:line-break">
        <xsl:element name="db:sbr"/>
    </xsl:template>

    <xsl:template match="text:a">
        <xsl:element name="db:link">
            <xsl:attribute name="xlink:href"><xsl:value-of select="@xlink:href"/></xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text:span">
        <xsl:variable name="text-style" select="key('styles-by-name', @text:style-name)"/>
        <xsl:variable name="child-text-style" select="key('styles-by-name', */@text:style-name)"/>
        <xsl:choose>
            <xsl:when test="$child-text-style and contains($text-style/style:text-properties/@fo:font-style, 'italic') and contains($child-text-style/style:text-properties/@fo:font-style, 'normal')">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="contains($text-style/style:text-properties/@fo:font-style, 'italic')">
                <xsl:element name="db:emphasis">
                    <!--[<xsl:value-of select="@text:style-name"/>|<xsl:value-of select="$text-style/style:text-properties/@fo:font-style"/>[ -->
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($text-style/style:text-properties/@style:text-position, 'sub')">
                <xsl:element name="db:subscript">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="contains($text-style/style:text-properties/@style:text-position, 'super')">
                <xsl:element name="db:superscript">
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="draw:frame/draw:image">
        <xsl:element name="db:mediaobject">
            <xsl:element name="db:imageobject">
                <xsl:element name="db:imagedata">
                    <xsl:attribute name="fileref"><xsl:value-of select="@xlink:href"/></xsl:attribute>
                    <xsl:attribute name="depth"><xsl:value-of select="parent::*/@svg:width"/></xsl:attribute>
                    <xsl:attribute name="height"><xsl:value-of select="parent::*/@svg:height"/></xsl:attribute>
                    <xsl:attribute name="fileref"><xsl:value-of select="@xlink:href"/></xsl:attribute>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text:bookmark-start">
        <xsl:element name="db:anchor">
            <xsl:attribute name="xml:id"><xsl:value-of select="@text:name"/></xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="table:table">
        <xsl:element name="db:table">
            <xsl:apply-templates/>                  
        </xsl:element>
    </xsl:template>

    <xsl:template match="table:table-row">
        <xsl:element name="db:row">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="table:table-cell">
        <xsl:element name="db:entry">
            <xsl:if test="@table:number-columns-spanned"><xsl:attribute name="colspan"><xsl:value-of select="@table:number-columns-spanned"/></xsl:attribute></xsl:if>
            <xsl:if test="@table:number-rows-spanned"><xsl:attribute name="rowspan"><xsl:value-of select="@table:number-rows-spanned"/></xsl:attribute></xsl:if>
            <xsl:if test="descendant::text:p[@text:class-names='table-heading']"><xsl:attribute name="role">heading</xsl:attribute></xsl:if>
            <xsl:if test="count(text:p) = 1">
                <xsl:variable name="style-alignment" select="key('styles-by-name', text:p/@text:style-name)/style:paragraph-properties/@fo:text-align"/>
                <xsl:variable name="parent-style-alignment" select="key('styles-by-name', key('styles-by-name', text:p/@text:style-name)/@style:parent-style-name)/style:paragraph-properties/@fo:text-align"/>
                <xsl:if test="normalize-space(concat($style-alignment,$parent-style-alignment))">
                    <xsl:attribute name="align">
                        <xsl:choose>
                            <xsl:when test="$style-alignment='start'">left</xsl:when>
                            <xsl:when test="$style-alignment='center'">center</xsl:when>
                            <xsl:when test="$style-alignment='end'">right</xsl:when>
                            <xsl:when test="$parent-style-alignment='start'">left</xsl:when>
                            <xsl:when test="$parent-style-alignment='center'">center</xsl:when>
                            <xsl:when test="$parent-style-alignment='end'">right</xsl:when>
                            <!--<xsl:otherwise><xsl:value-of select="$style-alignment"/>,<xsl:value-of select="$parent-style-alignment"/></xsl:otherwise>-->
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:if>
            </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template name="draw-section-level">
        <xsl:param name="descend-sections-or-apply-templates"/>
        <xsl:param name="outline-level"/>
        <xsl:param name="previous-outline-level"/>
        <xsl:choose>
            <xsl:when test="$outline-level - 1 = 0">
                <xsl:element name="db:chapter"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
            </xsl:when>
            <xsl:when test="$outline-level - 1 = 1">
                <xsl:element name="db:sect1"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
            </xsl:when>
            <xsl:when test="$outline-level - 1 = 2">
                <xsl:element name="db:sect2"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
            </xsl:when>
            <xsl:when test="$outline-level - 1 = 3">
                <xsl:element name="db:sect3"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
            </xsl:when>
            <xsl:when test="$outline-level - 1 = 4">
                <xsl:element name="db:sect4"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
            </xsl:when>
            <xsl:when test="$outline-level - 1 = 5">
                <xsl:element name="db:sect5"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
            </xsl:when>
            <xsl:when test="$outline-level - 1 = 6">
                <xsl:element name="db:sect6"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
            </xsl:when>
            <xsl:when test="$outline-level - 1 = 7">
                <xsl:element name="db:sect7"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
            </xsl:when>
            <xsl:when test="$outline-level - 1 = 8">
                <xsl:element name="db:sect8"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="db:sect9"><xsl:call-template name="draw-section-children"><xsl:with-param name="descend-sections-or-apply-templates" select="$descend-sections-or-apply-templates"/><xsl:with-param name="outline-level" select="$outline-level"/><xsl:with-param name="previous-outline-level" select="$previous-outline-level"/></xsl:call-template></xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="draw-section-children">
        <xsl:param name="descend-sections-or-apply-templates"/>
        <xsl:param name="outline-level"/>
        <xsl:param name="previous-outline-level"/>
        <xsl:choose>
            <xsl:when test="$descend-sections-or-apply-templates = 'descend sections'">
                <xsl:call-template name="section">
                    <xsl:with-param name="outline-level" select="$outline-level"/>
                    <xsl:with-param name="previous-outline-level" select="$previous-outline-level + 1"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="db:title"><xsl:apply-templates/></xsl:element>
                <xsl:apply-templates select="key('heading-children', generate-id())"/>
                <xsl:call-template name="apply-templates-children-headings"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="apply-templates-children-headings">
        <!--
        Temporary workaround until we can write xsl:keys for this function.
        TODO: can't use current() in patterns such as xsl:key http://www.w3.org/TR/xslt#function-current
        -->
        <xsl:variable name="generate-id" select="generate-id()"/>
        <xsl:variable name="outline-level" select="number(@text:outline-level)"/>
        <xsl:for-each select="following-sibling::text:h">
            <xsl:variable name="subheading-outline-level" select="@text:outline-level"/>
            <xsl:variable name="first-preceding-heading" select="./preceding-sibling::text:h[@text:outline-level &lt; $subheading-outline-level][1]"/>
            <xsl:if test="generate-id($first-preceding-heading) = $generate-id">
                <xsl:apply-templates select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
