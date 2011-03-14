# -*- coding: utf-8 -*-
import zipfile

class types(object):
    oasis_open_document = "oasis_open_document (any version)"
    pdf = "portable document format (any version)"
    unknown_type = "unknown file type"

def detect_document_type(data):
    data.seek(0)
    
    try:
        magic_bytes_open_document = 'PK'
        first_bytes = data.read(len(magic_bytes_open_document))
        if first_bytes.decode("utf-8") == magic_bytes_open_document:
            archive = zipfile.ZipFile(data)
            if 'mimetype' in archive.namelist() and archive.read('mimetype') == 'application/vnd.oasis.opendocument.text': # Step 2. ...but so are other types of file.
                return types.oasis_open_document
        magic_bytes_pdf = '%PDF'
        first_bytes = data.read(len(magic_bytes_pdf))
        if first_bytes.decode("utf-8") == magic_bytes_pdf:
            return types.pdf
    except UnicodeDecodeError, exception:
        pass
    return types.unknown_type
