# -*- coding: utf-8 -*-
import lxml.etree
import pipeline_item
import core.docvert_xml

class NormalizeOpenDocument(pipeline_item.pipeline_stage):

    def stage(self, pipeline_value):
        normalize_opendocument_path = self.resolve_pipeline_resource('internal://normalize-opendocument.xsl')
        return core.docvert_xml.transform(pipeline_value, normalize_opendocument_path)




