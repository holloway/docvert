# -*- coding: utf-8 -*-
import pipeline_item
import core.docvert_xml

class TransformOpenDocumentToDocBook(pipeline_item.pipeline_stage):

    def stage(self, pipeline_value):
        normalize_opendocument_path = self.resolve_pipeline_resource('internal://normalize-opendocument.xsl')
        pipeline_value = core.docvert_xml.transform(pipeline_value, normalize_opendocument_path)
        opendocument_to_docbook_path = self.resolve_pipeline_resource('internal://opendocument-to-docbook.xsl')
        return core.docvert_xml.transform(pipeline_value, opendocument_to_docbook_path)




