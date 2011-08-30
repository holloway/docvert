# -*- coding: utf-8 -*-
import zipfile
import StringIO
import time
import docvert_exception
import core.docvert_xml
import core.docvert_exception


class storage_type(object):
    file_based = "file based storage"
    memory_based = "memory based storage"

def get_storage(name):
    if name == storage_type.file_based:
        return storage_file_based()
    elif name == storage_type.memory_based:
        return storage_memory_based()
    raise docvert_exception.unrecognised_storage_type("Unknown storage type '%s'" % name)

class storage(object):
    _docvert_xml_namespace = '{docvert:5}'
    
    def __init__(self, *args, **kargs):
        raise NotImplemented()

    def __setitem__(self, key, value):
        self.add(key, value)

    def keys(self):
        return self.storage.keys()

    def has_key(self, key):
        return self.storage.has_key(key)

    def __getitem__(self, key):
        return self.get(key)

    def set_friendly_name(self, filename, friendly_name):
        raise NotImplemented()

    def add_tests(self, tests):
        if not hasattr(self, 'tests'):
            self.tests = []
        if type(tests) == type([]): #assume correctly formatted list
            return self.tests.extend(tests)
        document = core.docvert_xml.get_document(tests)
        if hasattr(document, 'getroottree'):
            document = document.getroottree()
        root = document.getroot()
        if root.tag != "%sgroup" % self._docvert_xml_namespace:
            raise docvert_exception.invalid_test_root_node("Error parsing test results. Expected a root node of 'group' but got '%s'" % root.tag)
        for child in root:
            if child.tag == "%spass" % self._docvert_xml_namespace:
                self.tests.append( {"status":"pass", "message":str(child.text)} )
            elif child.tag == "%sfail" % self._docvert_xml_namespace:
                self.tests.append(dict(status="fail", message=str(child.text)))
            else:
                raise invalid_test_child_node("Error parsing test results. Unexpected child element of '%s' %s" % (child.tag, child))

    def get_tests(self):
        if hasattr(self, 'tests'):
            return self.tests
        return list()


class storage_file_based(storage):
    def __init__(self):
        self.working_directory = tempfile.mkdtemp()
        self.created_at = time.time()
        self.default_document = None

    def add(self, path, data):
        handler = open(os.path.join(self.working_directory, path), 'w')
        handler.write(data)
        handler.close()

    def set_friendly_name(self, filename, friendly_name):
        raise NotImplemented()

    def get(self, path):
        handler = open(os.path.join(self.working_directory, path), 'r')
        return handler.read()

    def _dispose(self):
        os.removedirs(self.working_directory)

    def to_zip(self):
        raise NotImplemented("Not implemented, yet...")

    def __str__(self):
        return '<file based storage at path "%s">' % self.working_directory


class storage_memory_based(storage):
    def __init__(self):
        self.storage = dict()
        self.created_at = time.time()
        self.default_document = None
        self.friendly_names = dict()

    def add(self, path, data):
        self.storage[path] = data

    def set_friendly_name(self, filename, friendly_name):
        self.friendly_names[filename] = friendly_name

    def get_friendly_name_if_available(self, filename):
        if self.friendly_names.has_key(filename):
            return self.friendly_names[filename]
        return filename

    def keys(self):
        return self.storage.keys()

    def get(self, path):
        return self.storage[path]

    def remove(self, path):
        del self.storage[path]

    def __delitem__(self, path):
        del self.storage[path]

    def to_zip(self):
        zipdata = StringIO.StringIO()
        archive = zipfile.ZipFile(zipdata, 'w')
        for key, value in self.storage.iteritems():
            data = value
            if hasattr(value, "read"):
                data = value.seek(0)
                data = value.read()
            if not key.startswith("__"): #if it's not internal data
                archive.writestr(key.replace("\\", "/"), data)
        archive.close()
        return zipdata

    def _dispose(self):
        pass

    def __str__(self):
        return '<memory based storage with these keys "%s">' % self.storage.keys()
