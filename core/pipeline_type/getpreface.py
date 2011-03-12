# -*- coding: utf-8 -*-
import os
import lxml.etree
import StringIO
import pipeline_item
import core.docvert_exception


class GetPreface(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        return pipeline_value



