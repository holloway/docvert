# -*- coding: utf-8 -*-

import libreoffice

class document(object):
    def __init__(self, data):
        self.data = data

    def get_opendocument(self):
        raise NotImplemented()

class opendocument(document):
    def get_open_document(self):
        return self.data

    def set_dimensions(self, width, height):
        raise NotImplemented()

class binary_office_file(document)
    def get_opendocument(self):
        client = libreoffice.libreoffice_client()
        return client.convert_by_stream(self.data)


