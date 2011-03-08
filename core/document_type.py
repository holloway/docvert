# -*- coding: utf-8 -*-
import zipfile

class types(object):
    oasis_open_document = "oasis_open_document (any version)"
    unknown_type = "unknown_type"

def detect_document_type(data):
    data.seek(0)
    magic_bytes_open_document = 'PK' #Step 1. OpenDocument files are zip files...
    first_two_bytes = data.read(len(magic_bytes_open_document))
    if first_two_bytes.decode("utf-8") == magic_bytes_open_document:
        archive = zipfile.ZipFile(data)
        if 'mimetype' in archive.namelist() and archive.read('mimetype') == 'application/vnd.oasis.opendocument.text': # Step 2. ...but so are other types of file.
            return types.oasis_open_document
    return types.unknown_type
