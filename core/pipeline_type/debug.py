# -*- coding: utf-8 -*-
import lxml.etree
import pipeline_item
import core.docvert_exception

class Debug(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        if isinstance(pipeline_value, lxml.etree._Element):
            pipeline_value = lxml.etree.tostring(pipeline_value)
        elif isinstance(pipeline_value, lxml.etree._XSLTResultTree):
            pipeline_value = lxml.etree.tostring(pipeline_value)
        elif hasattr(pipeline_value, 'read'):
            pipeline_value = pipeline_value.read()
        help_text = "In debug mode we want to display an XML tree but if the root node is <html> or there's an HTML namespace then popular browsers will render it as HTML so these have been changed. See core/pipeline_type/debug.py for the details."
        document = lxml.etree.fromstring(pipeline_value)
        if hasattr(document, 'getroottree'):
            document = document.getroottree()
        if document.getroot().tag == "{http://www.w3.org/1999/xhtml}html":
            pipeline_value = "<root><!-- %s -->%s</root>" % (help_text, lxml.etree.tostring(document.getroot())) 
            pipeline_value = pipeline_value.replace('xmlns="http://www.w3.org/1999/xhtml"', 'xmlns="NON_HTML"')
        raise core.docvert_exception.debug_xml_exception("Current contents of XML", pipeline_value, "text/xml; charset=UTF-8")
