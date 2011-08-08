# -*- coding: utf-8 -*-
import os
import StringIO
import pipeline_item
import core.docvert_exception
import core.docvert_xml

class Transform(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        if not self.attributes.has_key("withFile"):
            raise no_with_file_attribute("In process Transform there wasn't a withFile attribute.")
        if pipeline_value is None:
            raise xml_empty("Cannot Transform with %s because pipeline_value is None." % self.attributes['withFile'])
        xslt_path = self.resolve_pipeline_resource(self.attributes['withFile'])
        if not os.path.exists(xslt_path):
            raise xslt_not_found("XSLT file not found at %s" % xslt_path)
        return core.docvert_xml.transform(pipeline_value, xslt_path)

class no_with_file_attribute(core.docvert_exception.docvert_exception):
    pass

class xslt_not_found(core.docvert_exception.docvert_exception):
    pass

class xml_empty(core.docvert_exception.docvert_exception):
    pass
