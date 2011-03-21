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
        try:
            document = lxml.etree.fromstring(pipeline_value)
        except lxml.etree.XMLSyntaxError, exception:
            raise core.docvert_exception.debug_exception("Current contents of pipeline", "Error parsing as XML, here it is as plain text: %s\n%s" % (exception, pipeline_value), "text/plain; charset=UTF-8")    
        content_type = 'text/xml'
        if self.attributes.has_key("contentType"):
            content_type = self.attributes['contentType']
        if content_type == 'text/xml':
            if hasattr(document, 'getroottree'):
                document = document.getroottree()
            if document.getroot().tag == "{http://www.w3.org/1999/xhtml}html":
                pipeline_value = "<root><!-- %s -->%s</root>" % (help_text, lxml.etree.tostring(document.getroot())) 
            pipeline_value = pipeline_value.replace('"http://www.w3.org/1999/xhtml"', '"XHTML_NAMESPACE_REPLACED_BY_DOCVERT_DURING_DEBUG_MODE"')
            xml_declaration = '<?xml version="1.0" ?>'
            if pipeline_value[0:5] != xml_declaration[0:5]:
                pipeline_value = xml_declaration + "\n" + pipeline_value
        raise core.docvert_exception.debug_xml_exception("Current contents of pipeline", pipeline_value, "%s; charset=UTF-8" % content_type)
