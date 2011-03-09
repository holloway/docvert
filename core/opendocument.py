# -*- coding: utf-8 -*-
import zipfile
import StringIO
import lxml.etree

def extract_useful_open_document_files(data):
    archive = zipfile.ZipFile(data)
    archive_files = archive.namelist()
    files_to_extract = ["content.xml", "meta.xml", "settings.xml", "styles.xml"]
    xml_string = StringIO.StringIO()
    xml_string.write('<docvert:root xmlns:docvert="docvert:5">')
    for file_to_extract in files_to_extract:
        if file_to_extract in archive_files:
            xml_string.write('<docvert:external-file xmlns:docvert="docvert:5" docvert:name="%s">' % file_to_extract)
            document = lxml.etree.fromstring(archive.open(file_to_extract).read())
            xml_string.write(lxml.etree.tostring(document))
            xml_string.write('</docvert:external-file>')
    xml_string.write('</docvert:root>')
    return xml_string
