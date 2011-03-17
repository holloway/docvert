# -*- coding: utf-8 -*-
import zipfile

class types(object):
    oasis_open_document = "oasis_open_document (any version)"
    pdf = "portable document format (any version)"
    xml = "xml"
    unknown_type = "unknown file type"

def detect_document_type(data):
    data.seek(0)
    try:
        # 1. Try OpenDocument
        magic_bytes_open_document = 'PK'
        first_bytes = data.read(len(magic_bytes_open_document))
        if first_bytes.decode("utf-8") == magic_bytes_open_document: # 1.1 Ok it's a ZIP but...
            archive = zipfile.ZipFile(data)
            if 'mimetype' in archive.namelist() and archive.read('mimetype') == 'application/vnd.oasis.opendocument.text': # 1.2 ...if it doesn't have these files it's not an OpenDocument
                return types.oasis_open_document
        # 2. Try PDF
        magic_bytes_pdf = '%PDF'
        first_bytes = data.read(len(magic_bytes_pdf))
        if first_bytes.decode("utf-8") == magic_bytes_pdf:
            return types.pdf
        # 3. Try XML ... XML doesn't have magic bytes per se (let alone a serialization format), and XML declarations aren't required in XML 1.0, but for our purposes we'll assume they exist. Please don't let this bit of code bite me in the ass.
        magic_bytes_xml = '<?xml version'
        first_bytes = data.read(len(magic_bytes_xml))
        if first_bytes.decode("utf-8") == magic_bytes_xml:
            return types.xml
    except UnicodeDecodeError, exception:
        pass
    finally:
        data.seek(0)
    return types.unknown_type
