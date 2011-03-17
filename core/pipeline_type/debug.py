# -*- coding: utf-8 -*-
import lxml.etree
import pipeline_item
import core.docvert_exception

class Debug(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        if isinstance(pipeline_value, lxml.etree._Element):
            pipeline_value = lxml.etree.tostring(pipeline_value)
        elif hasattr(pipeline_value, 'read'):
            pipeline_value = pipeline_value.read()
        raise core.docvert_exception.debug_xml_exception("Current contents of XML", pipeline_value, "text/xml; charset=UTF-8")
