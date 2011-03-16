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

class unknown_docvert_process(docvert_exception):
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
