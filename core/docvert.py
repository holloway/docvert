# -*- coding: utf-8 -*-
import tempfile
import os.path
import document_type
import docvert_exception
import docvert_pipeline
import docvert_storage
import docvert_libreoffice
import opendocument

class converter_type(object):
    python_streaming_to_libreoffice = "python streaming to libreoffice"

def process_conversion(files=None, urls=None, pipeline_id=None, auto_pipeline_id=None, storage_type_name=docvert_storage.storage_type.memory_based, converter=converter_type.python_streaming_to_libreoffice):
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
        pipeline_definition = docvert_pipeline.get_pipeline_definition(pipeline_id, auto_pipeline_id)
        pipeline = docvert_pipeline.pipeline_processor(storage, pipeline_definition['stages'], pipeline_definition['pipeline_directory'], filename)
        pipeline.start(document_xml)
    return storage

def generate_open_document(data, converter):
    if converter == converter_type.python_streaming_to_libreoffice:
        client = docvert_libreoffice.libreoffice_client()
        return client.convert_by_stream(data, docvert_libreoffice.LIBREOFFICE_OPEN_DOCUMENT)
    raise docvert_exception.unrecognised_converter("Unknown converter '%s'" % converter)

def get_all_pipelines():
    def _title(name):
        return name.replace('_',' ').replace('-',' ').title()
    docvert_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    pipeline_types_path = os.path.join(docvert_root, "pipelines")
    pipeline_types = dict()
    for pipeline_type in os.listdir(pipeline_types_path):
        pipeline_types[pipeline_type] = list()
        for pipeline_directory in os.listdir(os.path.join(pipeline_types_path, pipeline_type)):
            pipeline_types[pipeline_type].append(dict(id=pipeline_directory, name=_title(pipeline_directory)))
    return pipeline_types
    


