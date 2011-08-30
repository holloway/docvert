# -*- coding: utf-8 -*-
import zipfile
import StringIO
import lxml.etree
import os.path

def extract_useful_open_document_files(data, storage=None, prefix=None):
    archive = zipfile.ZipFile(data)
    archive_files = archive.namelist()
    xml_string = extract_xml(archive, archive_files)
    if storage is None: #we can't extract binaries
        return xml_string
    return extract_useful_binaries(archive, archive_files, storage, prefix, xml_string)

def extract_thumbnail(data):
    archive = zipfile.ZipFile(data)
    thumbnail_path = u'Thumbnails/thumbnail.png'
    archive_files = archive.namelist()
    if thumbnail_path in archive_files:
        return archive.open(thumbnail_path).read()
    return None


def extract_useful_binaries(archive, archive_files, storage, prefix, xml_string):
    xlink_namespace = "http://www.w3.org/1999/xlink"
    xpath_template = '//*[@{%s}href="%s"]' % (xlink_namespace, '%s')
    document = lxml.etree.fromstring(xml_string.getvalue())
    extensions = [".wmf", ".emf", ".svg", ".png", ".gif", ".bmp", ".jpg", ".jpe", ".jpeg"]
    index = 0
    for archive_path in archive_files:
        path_minus_extension, extension = os.path.splitext(archive_path)
        if extension in extensions:
            storage_path = u"%s/file%i.%s" % (prefix, index, extension)
            try:
                storage_path = u"%s/%s" % (prefix, os.path.basename(archive_path))
            except UnicodeDecodeError, e:
                pass
            #step 1. extract binaries
            storage[storage_path] = archive.open(archive_path).read() 
            #step 2. update XML references
            path_relative_to_xml = os.path.basename(archive_path)
            xpath = lxml.etree.ETXPath(xpath_template % archive_path)
            for match in xpath(document):
                match.attrib['{%s}href' % xlink_namespace] = storage_path
            index += 1
    return StringIO.StringIO(lxml.etree.tostring(document))

def extract_xml(archive, archive_files):
    xml_files_to_extract = ["content.xml", "meta.xml", "settings.xml", "styles.xml"]
    xml_string = StringIO.StringIO()
    xml_string.write('<docvert:root xmlns:docvert="docvert:5">')
    for xml_file_to_extract in xml_files_to_extract:
        if xml_file_to_extract in archive_files:
            xml_string.write('<docvert:external-file xmlns:docvert="docvert:5" docvert:name="%s">' % xml_file_to_extract)
            document = lxml.etree.fromstring(archive.open(xml_file_to_extract).read()) #parsing as XML to remove any doctype
            xml_string.write(lxml.etree.tostring(document))
            xml_string.write('</docvert:external-file>')
    xml_string.write('</docvert:root>')
    return xml_string
    
def generate_single_image_document(image_data, width, height):
    #print "Width/height: %s/%s" % (width,height) 
    #TODO: make document dimensions match image width/height
    content_xml = """<?xml version="1.0" encoding="UTF-8"?>
        <office:document-content office:version="1.2" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:css3t="http://www.w3.org/TR/css3-text/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:field="urn:openoffice:names:experimental:ooo-ms-interop:xmlns:field:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:formx="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:form:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:officeooo="http://openoffice.org/2009/office" xmlns:ooo="http://openoffice.org/2004/office" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:rpt="http://openoffice.org/2005/report" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:tableooo="http://openoffice.org/2009/table" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <office:body>
            <office:text>
              %s
            </office:text>
          </office:body>
        </office:document-content>"""
    mimetype = 'application/vnd.oasis.opendocument.text'
    image_xml = """<text:p text:style-name="Standard">
        <draw:frame draw:name="graphics1" draw:style-name="fr1" svg:width="%s" svg:height="%s" text:anchor-type="char">
          <draw:image xlink:actuate="onLoad" xlink:href="%s" xlink:show="embed" xlink:type="simple"/>
        </draw:frame></text:p>"""
    image_path = "Pictures/image.png"
    manifest = """<?xml version="1.0" encoding="UTF-8"?>
        <manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0">
            <manifest:file-entry manifest:media-type="application/vnd.oasis.opendocument.text" manifest:version="1.2" manifest:full-path="/"/>
            <manifest:file-entry manifest:media-type="image/png" manifest:full-path="%s"/>
            <manifest:file-entry manifest:media-type="" manifest:full-path="Pictures/"/>
            <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="content.xml"/>
            <manifest:file-entry manifest:media-type="text/xml" manifest:full-path="styles.xml"/>
        </manifest:manifest>"""
    styles_xml = """<?xml version="1.0" encoding="UTF-8"?>
        <office:document-styles grddl:transformation="http://docs.oasis-open.org/office/1.2/xslt/odf2rdf.xsl" office:version="1.2" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:grddl="http://www.w3.org/2003/g/data-view#" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0">
        <office:automatic-styles>
            <style:page-layout style:name="Mpm1">
              <style:page-layout-properties fo:background-color="#ffffff" fo:margin-bottom="0cm" fo:margin-left="0cm" fo:margin-right="0cm" fo:margin-top="0cm" fo:page-width="%s" fo:page-height="%s" style:footnote-max-height="0cm" style:layout-grid-base-height="0.635cm" style:layout-grid-base-width="0.369cm" style:layout-grid-color="#c0c0c0" style:layout-grid-display="false" style:layout-grid-lines="36" style:layout-grid-mode="none" style:layout-grid-print="false" style:layout-grid-ruby-below="false" style:layout-grid-ruby-height="0cm" style:layout-grid-snap-to-characters="true" style:num-format="1" style:print-orientation="portrait" style:writing-mode="lr-tb">
              </style:page-layout-properties>
            </style:page-layout>
          </office:automatic-styles>
          <office:master-styles>
            <style:master-page style:name="Standard" style:page-layout-name="Mpm1"/>
            <style:master-page style:display-name="First Page" style:name="First_20_Page" style:next-style-name="Standard" style:page-layout-name="Mpm1"/>
          </office:master-styles>
        </office:document-styles>"""
    image_xml = image_xml % (width, height, image_path) #filename doesn't matter
    zipio = StringIO.StringIO()
    archive = zipfile.ZipFile(zipio, 'w')
    archive.writestr('mimetype', mimetype)
    archive.writestr('content.xml', content_xml % image_xml)
    archive.writestr('styles.xml', styles_xml % (width, height))
    archive.writestr('META-INF/manifest.xml', manifest % image_path)
    archive.writestr(image_path, image_data)
    archive.close()
    zipio.seek(0)
    #pointer = file('/tmp/doc.odt', 'w')
    #pointer.write(zipio.read())
    #pointer.close()
    return zipio

