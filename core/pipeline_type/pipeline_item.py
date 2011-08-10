# -*- coding: utf-8 -*-
import os.path

docvert_root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

class pipeline_stage(object):
    def __init__(self, storage, pipeline_directory, attributes, pipeline_storage_prefix=None, child_stages=None, depth=None):
        self.storage = storage
        self.pipeline_directory = pipeline_directory
        self.pipeline_id = os.path.basename(pipeline_directory)
        self.pipeline_id_namespace = os.path.basename(os.path.dirname(pipeline_directory))
        self.attributes = attributes
        self.pipeline_storage_prefix = pipeline_storage_prefix
        self.child_stages = child_stages
        self.depth = list() if depth is None else depth

    def resolve_pipeline_resource(self, resource_path):
        internal_prefix = 'internal://'
        if resource_path.startswith(internal_prefix):
            return os.path.join(docvert_root, 'core', 'transform', resource_path[len(internal_prefix):])
        return os.path.join(docvert_root, "pipelines", self.pipeline_id_namespace, self.pipeline_id, resource_path)

    def log(self, message, log_type='error'):
        log_filename = '%s.log' % log_type
        storage_path = log_filename
        if self.pipeline_storage_prefix is not None:
            storage_path = "%s/%s" % (self.pipeline_storage_prefix, log_filename)
        self.storage[storage_path] = message

    def add_tests(self, tests):
        self.storage.add_tests(tests)

    def get_tests(self):
        return self.storage.get_tests()

