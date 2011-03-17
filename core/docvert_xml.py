# -*- coding: utf-8 -*-
import docvert_exception
import lxml.etree

def transform(data, xslt):
    xslt_document = get_document(xslt)
    xslt_processor = lxml.etree.XSLT(xslt_document)
    xml_document = get_document(data)
    return xslt_processor(xml_document)

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
        return lxml.etree.XML(file(data).read())
    else: #last ditch attempt...
        return lxml.etree.XML(str(data))
    raise docvert_exception.unable_to_generate_xml_document()



