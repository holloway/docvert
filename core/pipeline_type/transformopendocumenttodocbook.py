# -*- coding: utf-8 -*-
import lxml.etree
import pipeline_item
import core.docvert_xml
import core.docvert_exception

class TransformOpenDocumentToDocBook(pipeline_item.pipeline_stage):

    def stage(self, pipeline_value):
        normalize_opendocument_path = self.resolve_pipeline_resource('internal://normalize-opendocument.xsl')
        pipeline_value = core.docvert_xml.transform(pipeline_value, normalize_opendocument_path)
        if self.attributes.has_key("debugAfterNormalization"):
            pipeline_value = lxml.etree.tostring(pipeline_value)
            raise core.docvert_exception.debug_xml_exception("Current contents of pipeline", pipeline_value, 'text/xml')
        opendocument_to_docbook_path = self.resolve_pipeline_resource('internal://opendocument-to-docbook.xsl')
        return core.docvert_xml.transform(pipeline_value, opendocument_to_docbook_path)




