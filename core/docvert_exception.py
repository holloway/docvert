# -*- coding: utf-8 -*-

class docvert_exception(Exception):
    pass

class needs_files_or_urls(docvert_exception):
    pass

class unrecognised_pipeline(docvert_exception):
    pass

class unrecognised_auto_pipeline(docvert_exception):
    pass

class unrecognised_converter(docvert_exception):
    pass

class converter_unable_to_generate_open_document(docvert_exception):
    pass

class converter_unable_to_generate_pdf(docvert_exception):
    pass

class unknown_docvert_process(docvert_exception):
    pass

class unable_to_serialize_opendocument(docvert_exception):
    pass

class unrecognised_pipeline_item(docvert_exception):
    pass

class unrecognised_storage_type(docvert_exception):
    pass

class unknown_pipeline_node(docvert_exception):
    pass

class unknown_docvert_process(docvert_exception):
    pass

class tests_disabled(docvert_exception):
    pass

class unable_to_generate_xml_document(docvert_exception):
    pass

class invalid_test_root_node(docvert_exception):
    pass

class invalid_test_child_node(docvert_exception):
    pass

class debug_exception(docvert_exception):
    def __init__(self, message, data, content_type):
        self.data = data
        self.content_type = content_type
        super(docvert_exception, self).__init__(message)

class debug_xml_exception(debug_exception):
    pass
