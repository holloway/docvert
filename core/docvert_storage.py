# -*- coding: utf-8 -*-

class storage(object):
    def __init__(self, *args, **kargs):
        raise NotImplemented()

class storage_file_based(storage):
    def __init__(self):
        self.working_directory = tempfile.mkdtemp()

    def add(self, path, data):
        handler = open(os.path.join(self.working_directory, path), 'w')
        handler.write(data)
        handler.close()

    def get(self, path):
        handler = open(os.path.join(self.working_directory, path), 'r')
        return handler.read()

    def _dispose(self):
        os.removedirs(self.working_directory)

    def __str__(self):
        return '<file based storage at "%s">' % self.working_directory

class storage_memory_based(storage):
    def __init__(self):
        self.storage = dict()

    def add(self, path, data):
        self.storage[path] = data

    def get(self, path):
        return self.storage[path]

    def getzip(self):
        raise NotImplemented("Not implemented, yet...")

    def _dispose(self):
        pass

    def __str__(self):
        return '<memory based storage with "%s">' % self.storage.keys()
