# -*- coding: utf-8 -*-
import docvert_exception
import lxml.etree
import xml.sax.saxutils

def transform(data, xslt):
    xslt_document = get_document(xslt)
    xslt_processor = lxml.etree.XSLT(xslt_document)
    xml_document = get_document(data)
    return xslt_processor(xml_document)

def relaxng(data, relaxng_path):
    relaxng_document = get_document(relaxng_path)
    xml_document = get_document(data)
    relaxng_processor = lxml.etree.RelaxNG(relaxng_document)
    is_valid = relaxng_processor.validate(xml_document)
    return dict(valid=is_valid, log=relaxng_processor.error_log)

def escape_text(text):
    return xml.sax.saxutils.escape(text)

def get_document(data):
    if isinstance(data, lxml.etree._Element):
        return data
    elif isinstance(data, lxml.etree._XSLTResultTree):
        return data
    elif hasattr(data, 'read'):
        return lxml.etree.XML(data.read())
    elif data[0:1] == "/" or data[0:1] == "\\": #path
        return lxml.etree.XML(file(data).read())
    elif data[0:1] == "<": #xml
        return lxml.etree.XML(data)
    else: #last ditch attempt...
        return lxml.etree.XML(str(data))
    raise docvert_exception.unable_to_generate_xml_document()



