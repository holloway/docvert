# -*- coding: utf-8 -*-

class pipeline_stage(object):
    def __init__(self, storage, pipeline_directory, attributes):
        self.storage = storage
        self.pipeline_directory = pipeline_directory
        self.attributes = attributes
