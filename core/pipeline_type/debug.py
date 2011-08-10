# -*- coding: utf-8 -*-
import lxml.etree
import pipeline_item
import core.docvert_exception

class Debug(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        def get_value(data):
            if hasattr(data, "read"):
                data.seek(0)
                return data.read()
            return data
        if isinstance(pipeline_value, lxml.etree._Element) or isinstance(pipeline_value, lxml.etree._XSLTResultTree):
            pipeline_value = lxml.etree.tostring(pipeline_value)
        elif hasattr(pipeline_value, 'read'):
            pipeline_value.seek(0)
            pipeline_value = pipeline_value.read()
        if get_value(pipeline_value) is None:
            raise core.docvert_exception.debug_exception("Current contents of pipeline", "Debug: pipeline_value is %s" % get_value(pipeline_value), "text/plain; charset=UTF-8")
        try:
            document = lxml.etree.fromstring(get_value(pipeline_value))
        except lxml.etree.XMLSyntaxError, exception:
            raise core.docvert_exception.debug_exception("Current contents of pipeline", "Error parsing as XML, here it is as plain text: %s\n%s" % (exception, pipeline_value), "text/plain; charset=UTF-8")
        help_text = "In debug mode we want to display an XML tree but if the root node is <html> or there's an HTML namespace then popular browsers will\nrender it as HTML so these have been changed. See core/pipeline_type/debug.py for the details."
        unit_tests = self.get_tests()
        if unit_tests:
            #help_text += "\n\nUnit tests so far in the pipeline:"
            help_text += "\n\nFailed unit tests so far in the pipeline:"
            for value in self.get_tests():
                #help_text += "\n\t%s:%s" % (value["status"], value["message"])
                if value["status"] == "fail":
                    help_text += "\n\tFail: %s" % (value["message"])

        content_type = 'text/xml'
        if self.attributes.has_key("contentType"):
            content_type = self.attributes['contentType']
        if self.attributes.has_key("zip"):
            content_type = 'application/zip'
            pipeline_value = self.storage.to_zip().getvalue()
        if content_type == 'text/xml':
            help_text += "\n\nConversion files:\n\t" + "\n\t".join(self.storage.keys())
            if hasattr(document, 'getroottree'):
                document = document.getroottree()
            if document.getroot().tag == "{http://www.w3.org/1999/xhtml}html":
                pipeline_value = "<root><!-- %s -->%s</root>" % (help_text, lxml.etree.tostring(document.getroot())) 
            else:
                pipeline_value = "<!-- %s -->%s" % (help_text, lxml.etree.tostring(document.getroot())) 
            pipeline_value = pipeline_value.replace('"http://www.w3.org/1999/xhtml"', '"XHTML_NAMESPACE_REPLACED_BY_DOCVERT_DURING_DEBUG_MODE"')
            xml_declaration = '<?xml version="1.0" ?>'
            if pipeline_value[0:5] != xml_declaration[0:5]:
                pipeline_value = xml_declaration + "\n" + pipeline_value
        raise core.docvert_exception.debug_xml_exception("Current contents of pipeline", pipeline_value, content_type)
