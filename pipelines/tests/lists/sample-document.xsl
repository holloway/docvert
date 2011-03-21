<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="docvert:5">

	<xsl:output method="xml" omit-xml-declaration="no"/>

    <xsl:template match="/">
        <xsl:element name="group">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
