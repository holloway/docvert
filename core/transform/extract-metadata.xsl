<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet	version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:docvert="docvert:5">
<xsl:output	method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>

<xsl:template match="/">
    <xsl:copy-of select="//docvert:external-file[@docvert:name='meta.xml']/node()"/>
</xsl:template>

</xsl:stylesheet>

