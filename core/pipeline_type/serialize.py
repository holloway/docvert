# -*- coding: utf-8 -*-
import os
import pipeline_item
import lxml.etree

class Serialize(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        storage_path = "%s/%s" % (self.pipeline_storage_prefix, self.attributes['toFile'])
        if self.pipeline_storage_prefix is None:
            storage_path = self.attributes['toFile']
        if '{customSection}' in storage_path:
            depth_string = 'section'
            depth_string += "-".join(self.depth)
            depth_string += ".html"
            storage_path = storage_path.replace('{customSection}', depth_string) 
        if hasattr(pipeline_value, 'read'):
            self.storage[storage_path] = str(pipeline_value)
        elif isinstance(pipeline_value, lxml.etree._Element) or isinstance(pipeline_value, lxml.etree._XSLTResultTree):
            self.storage[storage_path] = lxml.etree.tostring(pipeline_value)
        else:
            self.storage[storage_path] = str(pipeline_value)
        return pipeline_value


