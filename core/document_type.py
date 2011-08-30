# -*- coding: utf-8 -*-
import zipfile
import StringIO

class types(object):
    oasis_open_document = "oasis_open_document (any version)"
    pdf = "portable document format (any version)"
    xml = "xml"
    html = "html"
    exception = "exception"
    unknown_type = "unknown file type"

def detect_document_type(data):
    if isinstance(data, Exception):
        return types.exception
    if isinstance(data, str):
        data = StringIO.StringIO(data)
    try:
        # 1. Sniff for OpenDocument
        magic_bytes_open_document = 'PK'
        data.seek(0)
        first_bytes = data.read(len(magic_bytes_open_document))
        if first_bytes.decode("utf-8") == magic_bytes_open_document: # 1.1 Ok it's a ZIP but...
            archive = zipfile.ZipFile(data)
            if 'mimetype' in archive.namelist() and archive.read('mimetype') == 'application/vnd.oasis.opendocument.text': # 1.2 ...if it doesn't have these files it's not an OpenDocument
                return types.oasis_open_document
        # 2. Sniff for PDF
        magic_bytes_pdf = '%PDF'
        data.seek(0)
        first_bytes = data.read(len(magic_bytes_pdf))
        if first_bytes.decode("utf-8") == magic_bytes_pdf:
            return types.pdf
    except UnicodeDecodeError, exception:
        pass
    finally:
        data.seek(0)
    return types.unknown_type
