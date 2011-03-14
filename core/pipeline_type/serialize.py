# -*- coding: utf-8 -*-
import os
import pipeline_item

class Serialize(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        storage_path = "%s/%s" % (self.pipeline_storage_prefix, self.attributes['toFile'])
        if self.pipeline_storage_prefix is None:
            storage_path = self.attributes['toFile']
        self.storage[storage_path] = str(pipeline_value)
        return pipeline_value


