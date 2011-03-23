# -*- coding: utf-8 -*-
import pipeline_item
import core.docvert_xml

class DocBookToXHTML(pipeline_item.pipeline_stage):
    docbook_to_html_path = self.resolve_pipeline_resource('internal://docbook-to-html.xsl')

    def stage(self, pipeline_value):
        return core.docvert_xml.transform(pipeline_value, self.docbook_to_html_path)



