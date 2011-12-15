# -*- coding: utf-8 -*-
import tempfile
import StringIO
import os.path
import document_type
import docvert_exception
import docvert_pipeline
import docvert_storage
import docvert_libreoffice
import docvert_xml
import opendocument
import urllib2

docvert_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
version = '5.1'
http_timeout = 10

class converter_type(object):
    python_streaming_to_libreoffice = "python streaming to libreoffice"

def process_conversion(files=None, urls=None, pipeline_id=None, pipeline_type="pipelines", auto_pipeline_id=None, storage_type_name=docvert_storage.storage_type.memory_based, converter=converter_type.python_streaming_to_libreoffice, suppress_errors=False):
    if files is None and urls is None:
        raise docvert_exception.needs_files_or_urls()
    if pipeline_id is None:
        raise docvert_exception.unrecognised_pipeline("Unknown pipeline '%s'" % pipeline_id)
    storage = docvert_storage.get_storage(storage_type_name)

    def _title(name, files, data):
        filename = os.path.basename(name).replace('\\','-').replace('/','-').replace(':','-')
        if len(filename) == 0:
            filename = "document.odt"
        if files.has_key(filename):
            if data and hasattr(files[filename], 'read') and files[filename].getvalue() == data:
                return filename
            unique = 1
            potential_filename = filename
            while files.has_key(potential_filename):
                unique += 1
                if filename.count("."):
                    potential_filename = filename.replace(".", "%i." % unique, 1)
                else:
                    potential_filename = filename + str(unique)
            filename = potential_filename
        return filename

    for url in urls:
        try:
            data = urllib2.urlopen(url, None, http_timeout).read()
            doc_type = document_type.detect_document_type(data)
            if doc_type == document_type.types.html:
                data = html_to_opendocument(data, url)
            filename = _title(url, files, data)
            storage.set_friendly_name(filename, "%s (%s)" % (filename, url))
            files[filename] = StringIO.StringIO(data)
        except IOError, e:
            filename = _title(url, files, None)
            storage.set_friendly_name(filename, "%s (%s)" % (filename, url))
            files[filename] = Exception("Download error from %s: %s" % (url, e))
    for filename, data in files.iteritems():
        if storage.default_document is None:
            storage.default_document = filename
        doc_type = document_type.detect_document_type(data)
        if doc_type == document_type.types.exception:
            storage.add("%s/index.txt" % filename, str(data))
        elif doc_type != document_type.types.oasis_open_document:
            try:
                data = generate_open_document(data, converter)
                doc_type = document_type.types.oasis_open_document
            except Exception, e:
                if not suppress_errors:
                    raise e
                storage.add("%s/index.txt" % filename, str(e))
        if doc_type == document_type.types.oasis_open_document:
            if pipeline_id == "open document": #reserved term, for when people want the Open Document file back directly. Don't bother loading pipeline.
                storage.add("%s/index.odt" % filename, data)
                thumbnail = opendocument.extract_thumbnail(data)
                if thumbnail:
                    storage.add("%s/thumbnail.png" % filename, thumbnail)
            else:
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

def html_to_opendocument(html, url):
    from BeautifulSoup import BeautifulSoup
    import htmlentitydefs
    import re

    def to_ncr(match):
        text = match.group(0)
        entity_string = text[1:-1]
        entity = htmlentitydefs.entitydefs.get(entity_string)
        if entity:
            if len(entity) > 1:
                return entity
            try:
                return "&#%s;" % ord(entity)
            except ValueError:
                pass
            except TypeError, e:
                print "TypeError on '%s'?" % entity
                raise
        return text

    soup = BeautifulSoup(html, convertEntities=BeautifulSoup.XML_ENTITIES)
    to_extract = soup.findAll('script')
    for item in to_extract:
        item.extract()
    pretty_xml = soup.html.prettify()
    pretty_xml = re.sub("&?\w+;", to_ncr, pretty_xml)
    pretty_xml = re.sub('&(\w+);', '&amp;\\1', pretty_xml)
    pretty_xml = pretty_xml.replace("& ", "&amp; ")
    #display_lines(pretty_xml, 5, 15)
    xml = docvert_xml.get_document(pretty_xml)
    storage = docvert_storage.get_storage(docvert_storage.storage_type.memory_based)
    result = process_pipeline(xml, 'default', 'html_to_opendocument', None, storage)
    #print result
    #print storage
    return result

def display_lines(data, start_line, end_line):
    data = data.split("\n")
    segment = data[start_line:end_line]
    for line in segment:
        print "%s%s" % (start_line, line)
        start_line += 1
    

def get_all_pipelines(include_default_autopipeline = True):
    def _title(name):
        if name.endswith('.default'):
            name = name[0:-len('.default')]
        return name.replace('_',' ').replace('-',' ').title()

    pipeline_types_path = os.path.join(docvert_root, "pipelines")
    pipeline_types = dict()
    for pipeline_type in os.listdir(pipeline_types_path):
        pipeline_types[pipeline_type] = list()
        for pipeline_directory in os.listdir(os.path.join(pipeline_types_path, pipeline_type)):
            if pipeline_directory == 'ssc': #don't show this pipeline publicly. it's not important.
                pass
            elif include_default_autopipeline is False and pipeline_type == "auto_pipelines" and "nothing" in pipeline_directory.lower():
                pass #print "Skipping?"
            else:
                pipeline_types[pipeline_type].append(dict(id=pipeline_directory, name=_title(pipeline_directory)))
    return pipeline_types
    

