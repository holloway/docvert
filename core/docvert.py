# -*- coding: utf-8 -*-
import os
import tempfile
import lxml.etree
import zipfile
import StringIO
import document_type
import docvert_exception
import docvert_pipeline
import docvert_storage

docvert_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

class converter_type(object):
    python_streaming_to_libreoffice = "python streaming to libreoffice"

class storage_type(object):
    file_based = "file based storage"
    memory_based = "memory based storage"

def process_conversion(files, pipeline_name=None, auto_pipeline_name=None, storage_type_name=storage_type.memory_based, converter=converter_type.python_streaming_to_libreoffice):
    if pipeline_name is None:
        raise docvert_exception.unrecognised_pipeline("Unknown pipeline '%s'" % pipeline_name)
    storage = get_storage(storage_type_name)
    for filename, data in files.iteritems():
        doc_type = document_type.detect_document_type(data)
        if doc_type != document_type.types.oasis_open_document:
            data = generate_open_document(data, converter)
        document_xml = extract_useful_open_document_files(data)
        return document_xml
        pipeline_xml = get_pipeline(pipeline_name, auto_pipeline_name)
        pipeline = docvert_pipeline.pipeline_processor(storage, pipeline_xml, document_xml)
        pipeline.start()

    return storage

def generate_open_document(data, converter):
    if converter == converter_type.python_streaming_to_libreoffice:
        import docvert_libreoffice
        client = docvert_libreoffice.libreoffice_client()
        return client.convert_by_stream(data)
    raise docvert_exception.unrecognised_converter("Unknown converter '%s'" % converter)

def get_pipeline(pipeline_name, auto_pipeline_name):
    path = os.path.join(docvert_root, "pipelines", "pipeline", pipeline_name, "pipeline.xml")
    if not os.path.exists(path):
        raise docvert_exception.unrecognised_pipeline("Unknown pipeline '%s'" % name)
    xml = lxml.etree.parse(path)
    if xml.getroot().tag == "autopipeline":
        if auto_pipeline_name is None:
            raise docvert_exception.unrecognised_auto_pipeline("Unknown auto pipeline '%s'" % auto_pipeline_name)
        raise Exception("Sorry, auto pipelines aren't implemented yet.")
        path = os.path.join(docvert_root, "pipelines", "autopipeline", auto_pipeline_name, "pipeline.xml")
        if not os.path.exists(path):
            raise docvert_exception.unrecognised_auto_pipeline("Unknown auto pipeline '%s'" % auto_pipeline_name)
    return xml

def get_storage(name):
    if name == storage_type.file_based:
        return docvert_storage.storage_file_based()
    elif name == storage_type.memory_based:
        return docvert_storage.storage_memory_based()
    raise docvert_exception.unrecognised_storage_type("Unknown storage type '%s'" % name)

def extract_useful_open_document_files(data):
    archive = zipfile.ZipFile(data)
    archive_files = archive.namelist()
    files_to_extract = ["content.xml", "meta.xml", "settings.xml", "styles.xml"]
    xml_string = StringIO.StringIO()
    xml_string.write('<docvert:root xmlns:docvert="docvert:5">')
    for file_to_extract in files_to_extract:
        if file_to_extract in archive_files:
            xml_string.write('<docvert:external-file xmlns:docvert="docvert:5" docvert:name="%s">' % file_to_extract)
            document = lxml.etree.fromstring(archive.open(file_to_extract).read())
            xml_string.write(lxml.etree.tostring(document))
            xml_string.write('</docvert:external-file>')
    xml_string.write('</docvert:root>')
    return xml_string.getvalue()



