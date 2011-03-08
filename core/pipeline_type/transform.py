import core.pipeline
import lxml

class transform(core.pipeline.pipeline_item):
    def __init__(self, processor, **params):
        self.processor = processor

    def stage(self, value):
        xml.etree(value)
