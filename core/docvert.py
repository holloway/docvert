# -*- coding: utf-8 -*-
import tempfile
import os.path
import document_type
import docvert_exception
import docvert_pipeline
import docvert_storage
import docvert_libreoffice
import opendocument

docvert_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
version = '5.0'

class converter_type(object):
    python_streaming_to_libreoffice = "python streaming to libreoffice"

def process_conversion(files=None, urls=None, pipeline_id=None, pipeline_type="pipelines", auto_pipeline_id=None, storage_type_name=docvert_storage.storage_type.memory_based, converter=converter_type.python_streaming_to_libreoffice):
    if files is None and urls is None:
        raise docvert_exception.needs_files_or_urls()
    if pipeline_id is None:
        raise docvert_exception.unrecognised_pipeline("Unknown pipeline '%s'" % pipeline_id)
    storage = docvert_storage.get_storage(storage_type_name)
    for filename, data in files.iteritems():
        doc_type = document_type.detect_document_type(data)
        if doc_type != document_type.types.oasis_open_document:
            data = generate_open_document(data, converter)
        document_xml = opendocument.extract_useful_open_document_files(data, storage, filename)
        process_pipeline(document_xml, pipeline_id, pipeline_type, auto_pipeline_id, storage, filename)
    return storage

def process_pipeline(initial_pipeline_value, pipeline_id, pipeline_type, auto_pipeline_id, storage, storage_prefix=None):
    pipeline_definition = docvert_pipeline.get_pipeline_definition(pipeline_type, pipeline_id, auto_pipeline_id)
    pipeline = docvert_pipeline.pipeline_processor(storage, pipeline_definition['stages'], pipeline_definition['pipeline_directory'], storage_prefix)
    return pipeline.start(initial_pipeline_value)

def generate_open_document(data, converter=converter_type.python_streaming_to_libreoffice):
    if converter == converter_type.python_streaming_to_libreoffice:
        return docvert_libreoffice.get_client().convert_by_stream(data, docvert_libreoffice.LIBREOFFICE_OPEN_DOCUMENT)
    raise docvert_exception.unrecognised_converter("Unknown converter '%s'" % converter)

def get_all_pipelines():
    def _title(name):
        if name.endswith('.default'):
            name = name[0:-len('.default')]
        return name.replace('_',' ').replace('-',' ').title()

    pipeline_types_path = os.path.join(docvert_root, "pipelines")
    pipeline_types = dict()
    for pipeline_type in os.listdir(pipeline_types_path):
        pipeline_types[pipeline_type] = list()
        for pipeline_directory in os.listdir(os.path.join(pipeline_types_path, pipeline_type)):
            pipeline_types[pipeline_type].append(dict(id=pipeline_directory, name=_title(pipeline_directory)))
    return pipeline_types
    

