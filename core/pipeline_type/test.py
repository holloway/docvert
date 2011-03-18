# -*- coding: utf-8 -*-
import os
import os.path
import lxml.etree
import StringIO
import pipeline_item
import core.docvert_exception
import core.docvert
import core.docvert_xml


class Test(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        if not self.attributes.has_key("withFile"):
            raise no_with_file_attribute("In process Transform there wasn't a withFile attribute.")
        if pipeline_value is None:
            raise xml_empty("Cannot Test with %s because pipeline_value is None." % self.attributes['withFile'])
        test_result = None
        test_path = self.resolve_pipeline_resource(self.attributes['withFile'])
        if not os.path.exists(test_path):
            raise file_not_found("Test file not found at %s" % test_path)
        if test_path.endswith(".rng"):
            relaxng_response = core.docvert_xml.relaxng(pipeline_value, test_path)
            node_name = "pass"
            if not relaxng_response["valid"]:
                node_name = "fail"
            test_result = '<group xmlns="docvert:5"><%s>%s</%s></group>' % (node_name, core.docvert_xml.escape_text(str(relaxng_response["log"])), node_name)
        else: #default to XSLT
            test_result = core.docvert_xml.transform(pipeline_value, test_path)
        if self.attributes.has_key("debug"):
            raise core.docvert_exception.debug_xml_exception("Test Results", str(test_result), "text/xml; charset=UTF-8")
        self.add_tests(test_result)
        return pipeline_value        


class no_with_file_attribute(core.docvert_exception.docvert_exception):
    pass

class file_not_found(core.docvert_exception.docvert_exception):
    pass

class xml_empty(core.docvert_exception.docvert_exception):
    pass
