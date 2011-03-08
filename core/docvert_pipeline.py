# -*- coding: utf-8 -*-
import docvert_exception

class pipeline_processor(object):
    """ Processes through a list() of pipeline_item(s) """
    def __init__(self, storage, pipeline_items, initial_pipeline_value=None):
        self.storage = storage
        self.pipeline_items = pipeline_items
        self.pipeline_value = initial_pipeline_value

    def start(self, initial_pipeline_value=None):
        if initial_pipeline_value is not None:
            self.pipeline_value = initial_pipeline_value
        if self.pipeline_value is None:
            raise docvert_exception.initial_pipeline_value_needed_exception()
        return self.process_items()

    def process_pipeline_items(self):
        for item in self.pipeline_items:
            if isinstance(item, dict) and item.has_key('process'):
                try:
                    item_class = __import__(item['process'], fromlist=["core.pipeline_type.%s" % item['process']])
                    item = item_class(processor=self, **item)
                except ImportError:
                    raise unknown_docvert_process("Unknown docvert process of %s" % item['process'])
            if isinstance(item, list):
                pass
            elif isinstance(item, pipeline_item):
                self.process_pipeline_items(pipeline_item, pipeline_value)
                pipeline_value = pipeline_item.stage(pipeline_value)
            else:
                raise unrecognised_pipeline_item()
        return pipeline_value

