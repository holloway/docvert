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

def extract_useful_binaries(archive, archive_files, storage, prefix, xml_string):
    xlink_namespace = "http://www.w3.org/1999/xlink"
    xpath_template = '//*[@{%s}href="%s"]' % (xlink_namespace, '%s')
    document = lxml.etree.fromstring(xml_string.getvalue())
    extensions = [".wmf", ".emf", ".svg", ".png", ".gif", ".bmp", ".jpg", ".jpe", ".jpeg"]
    for archive_path in archive_files:
        path_minus_extension, extension = os.path.splitext(archive_path)
        if extension in extensions:
            storage_path = "%s/%s" % (prefix, os.path.basename(archive_path))
            #step 1. extract binaries
            storage[storage_path] = archive.open(archive_path).read() 
            #step 2. update XML references
            path_relative_to_xml = os.path.basename(archive_path)
            xpath = lxml.etree.ETXPath(xpath_template % archive_path)
            for match in xpath(document):
                match.attrib['{%s}href' % xlink_namespace] = storage_path
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
    
