# -*- coding: utf-8 -*-
import os
import pipeline_item
import core.docvert_exception
import core.docvert_xml
import lxml.etree

class WriteMetaData(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        opendocument_xml_path = "%s/%s" % (self.pipeline_storage_prefix, 'opendocument.xml')
        xslt_path = self.resolve_pipeline_resource('internal://extract-metadata.xsl')
        if not os.path.exists(xslt_path):
            raise xslt_not_found("XSLT file not found at %s" % xslt_path)
        metadata_xml_path = "%s/%s" % (self.pipeline_storage_prefix, 'docvert-meta.xml')
        metadata_xml = core.docvert_xml.transform(self.storage.get(opendocument_xml_path), xslt_path)
        if isinstance(metadata_xml, lxml.etree._Element) or isinstance(metadata_xml, lxml.etree._XSLTResultTree):
            metadata_xml = lxml.etree.tostring(metadata_xml)
        self.storage[metadata_xml_path] = metadata_xml
        return pipeline_value

class xslt_not_found(core.docvert_exception.docvert_exception):
    pass


