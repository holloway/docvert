# -*- coding: utf-8 -*-

class pipeline_stage(object):
    def __init__(self, storage, pipeline_directory, attributes, pipeline_storage_prefix=None):
        self.storage = storage
        self.pipeline_directory = pipeline_directory
        self.attributes = attributes
        self.pipeline_storage_prefix = pipeline_storage_prefix
