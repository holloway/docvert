# -*- coding: utf-8 -*-
import os
import os.path
import lxml.etree
import StringIO
import pipeline_item
import core.docvert
import core.opendocument
import core.document_type
import core.docvert_exception

class Generate(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        if pipeline_value is not None:
            raise pipeline_value_not_empty()
        if not self.attributes.has_key('withFile'):
            raise needs_with_file_attribute("A process type of Generate needs a withFile attribute containing a filename/path.")
        path = self.resolve_pipeline_resource(self.attributes['withFile'])
        if not os.path.exists(path):
            raise generation_file_not_found("A process type of Generate couldn't find a file at %s" % path)
        data = file(path)
        doc_type = core.document_type.detect_document_type(data)
        if doc_type != core.document_type.types.oasis_open_document:
            data = core.docvert.generate_open_document(data)
        document_xml = core.opendocument.extract_useful_open_document_files(data, self.storage, os.path.basename(path))
        return document_xml

class pipeline_value_not_empty(core.docvert_exception.docvert_exception):
    pass

class needs_with_file_attribute(core.docvert_exception.docvert_exception):
    pass

class generation_file_not_found(core.docvert_exception.docvert_exception):
    pass
