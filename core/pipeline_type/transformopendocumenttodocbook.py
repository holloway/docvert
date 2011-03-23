# -*- coding: utf-8 -*-
import pipeline_item

class TransformOpenDocumentToDocBook(pipeline_item.pipeline_stage):
    normalize_opendocument_path = self.resolve_pipeline_resource('internal://normalize-opendocument.xsl')
    opendocument_to_docbook_path = self.resolve_pipeline_resource('internal://opendocument-to-docbook.xsl')

    def stage(self, pipeline_value):
        pipeline_value = core.docvert_xml.transform(pipeline_value, self.normalize_opendocument_path)
        return core.docvert_xml.transform(pipeline_value, self.opendocument_to_docbook_path)




