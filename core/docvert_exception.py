class docvert_exception(Exception):
    pass

class unrecognised_pipeline(docvert_exception):
    pass

class unrecognised_auto_pipeline(docvert_exception):
    pass

class unrecognised_converter(docvert_exception):
    pass


class unknown_docvert_process(docvert_exception):
    pass

class initial_pipeline_value_needed_exception(docvert_exception):
    pass

class unrecognised_pipeline_item(docvert_exception):
    pass

class unrecognised_storage_type(docvert_exception):
    pass

