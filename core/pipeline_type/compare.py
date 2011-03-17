# -*- coding: utf-8 -*-
import os
import os.path
import lxml.etree
import pipeline_item
import core.docvert
import core.docvert_exception
import core.docvert_xml
import core.document_type
import core.opendocument

class Compare(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        if pipeline_value is None:
            raise pipeline_value_not_empty("A process type of Compare needs pipeline_value to compare with.")
        if not self.attributes.has_key('withFile'):
            raise needs_with_file_attribute("A process type of Compare needs a withFile attribute containing a filename/path.")
        compare_path = self.resolve_pipeline_resource(self.attributes['withFile'])
        if not os.path.exists(compare_path):
            raise generation_file_not_found("A process type of Compare couldn't find a file at %s" % compare_path)
        compare_data = file(compare_path)
        compare_xml = None
        doc_type = core.document_type.detect_document_type(compare_data)
        if doc_type == core.document_type.types.oasis_open_document:
            compare_xml = core.opendocument.extract_useful_open_document_files(compare_data)
        elif doc_type == core.document_type.types.xml:
            compare_xml = compare_data
        else:
            raise cannot_compare_with_non_xml_or_non_opendocument("Cannot compare withFile=%s with detected type of %s" % (compare_path, doc_type))
        turn_document_into_test_filename = "internal://turn-document-into-test.xsl"
        xslt_path = self.resolve_pipeline_resource(turn_document_into_test_filename)
        test_xslt = core.docvert_xml.transform(compare_data, xslt_path)
        storage_filename = "comparision-to-%s.xhtml" % self.attributes['withFile']
        storage_path = "%s/%s" % (self.pipeline_storage_prefix, storage_filename)
        if self.pipeline_storage_prefix is None:
            storage_path = storage_filename
        print storage_path
        storage[storage_path] = core.docvert_xml.transform(pipeline_value, test_as_xslt)
        return pipeline_value

class pipeline_value_not_empty(core.docvert_exception.docvert_exception):
    pass

class needs_with_file_attribute(core.docvert_exception.docvert_exception):
    pass

class generation_file_not_found(core.docvert_exception.docvert_exception):
    pass

class cannot_compare_with_non_xml_or_non_opendocument(core.docvert_exception.docvert_exception):
    pass

