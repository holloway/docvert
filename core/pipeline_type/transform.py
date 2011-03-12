# -*- coding: utf-8 -*-
import os
import lxml.etree
import StringIO
import pipeline_item
import core.docvert_exception


class Transform(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        xslt_path = os.path.join(self.pipeline_directory, self.attributes['withFile'])
        if not os.path.exists(xslt_path):
            raise xslt_not_found("XSLT file not found at %s" % xslt_path)
        xslt_string = open(xslt_path).read()
        xslt_document = lxml.etree.XML(xslt_string)
        #print "XSLT was %s" % xslt_string
        transform = lxml.etree.XSLT(xslt_document)
        pipeline_document = None
        if hasattr(pipeline_value, 'getvalue'):
            pipeline_document = lxml.etree.XML(pipeline_value.getvalue())
        elif hasattr(pipeline_value, 'read'):
            pipeline_document = lxml.etree.XML(pipeline_value.read())
        elif isinstance(pipeline_value, lxml.etree._Element):
            pass
        else: #last ditch attempt...
            pipeline_document = lxml.etree.XML(str(pipeline_value))
        return transform(pipeline_document)

class xslt_not_found(core.docvert_exception.docvert_exception):
    pass
