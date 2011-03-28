# -*- coding: utf-8 -*-
import os
import pipeline_item
import copy
import core.docvert_exception
import core.docvert_pipeline
import core.docvert_xml
import lxml.etree

class Loop(pipeline_item.pipeline_stage):
    def stage(self, pipeline_value):
        if not self.attributes.has_key('numberOfTimes'):
            raise no_number_of_times_attribute("In process Loop there wasn't a numberOfTimes attribute.")
        
        numberOfTimes = self.attributes['numberOfTimes']
        if numberOfTimes.startswith('xpathCount:'):
            xpath = numberOfTimes[len('xpathCount:'):]
            xml = core.docvert_xml.get_document(pipeline_value)
            namespaces = {
                'xlink':'http://www.w3.org/1999/xlink',
                'db':'http://docbook.org/ns/docbook',
                'text':'urn:oasis:names:tc:opendocument:xmlns:text:1.0',
                'office':'urn:oasis:names:tc:opendocument:xmlns:office:1.0',
                'html':'http://www.w3.org/1999/xhtml',
                'xhtml':'http://www.w3.org/1999/xhtml'}
            nodes = xml.xpath(xpath, namespaces=namespaces)
            index = 0
            for node in nodes:
                index += 1
                child_depth = copy.copy(self.depth)
                child_depth.append(str(index))
                pipeline = core.docvert_pipeline.pipeline_processor(self.storage, self.child_stages, self.pipeline_directory, self.pipeline_storage_prefix, child_depth)
                child_pipeline_value = lxml.etree.tostring(pipeline_value)
                pipeline.start(child_pipeline_value) #discard return value
        elif numberOfTimes.startswith('substring:'):
            number = int(numberOfTimes[len('substring:'):])
            for index in range(1, number):
                pass
        elif numberOfTimes.startswith('number:'):
            number = int(numberOfTimes[len('number:'):])
            for index in range(1, number):
                pass
        return pipeline_value

class no_number_of_times_attribute(core.docvert_exception.docvert_exception):
    pass

