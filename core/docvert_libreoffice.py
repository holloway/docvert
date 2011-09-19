# -*- coding: utf-8 -*-
from os.path import abspath
from os.path import isfile
from os.path import splitext
import sys
from StringIO import StringIO
import document_type
import docvert_exception
import socket

DEFAULT_LIBREOFFICE_PORT = 2002
LIBREOFFICE_OPEN_DOCUMENT = 'writer8'
LIBREOFFICE_PDF = 'writer_pdf_Export'

client = None

try:
    import uno
except ImportError:
    sys.path.append('/opt/libreoffice/program/')
    sys.path.append('/usr/lib/libreoffice/program/')
    sys.path.append('/usr/share/libreoffice/program/')
    sys.path.append('/usr/lib/openoffice.org/program/')
    sys.path.append('/usr/lib/openoffice.org2.0/program/')
    try:
        import uno
    except ImportError:
        python_version_info = sys.version_info
        python_version = "%s.%s.%s" % (python_version_info[0], python_version_info[1], python_version_info[2])
        alternate_python_version = "2.6"
        the_command_they_ran = " ".join(sys.argv)
        if python_version.startswith("2.6"):
              alternate_python_version = "2.7"
        sys.stderr.write("Error: Unable to find Python UNO libraries in %s.\nAre Python UNO libraries somewhere else?\nAlternatively, Docvert is currently running Python %s so perhaps Python %s has Python UNO libraries? If so, then try calling %s with that version of python (either as 'python%s %s' or change the first line of %s)\nExiting...\n" % (sys.path, python_version, alternate_python_version, the_command_they_ran, alternate_python_version, the_command_they_ran, the_command_they_ran))
        sys.exit(0)
        
import unohelper
from com.sun.star.beans import PropertyValue
from com.sun.star.task import ErrorCodeIOException
from com.sun.star.uno import Exception as UnoException
from com.sun.star.connection import NoConnectException
from com.sun.star.io import XOutputStream

class output_stream_wrapper(unohelper.Base, XOutputStream):
    def __init__(self):
        self.data = StringIO()
        self.position = 0

    def writeBytes(self, bytes):
        self.data.write(bytes.value)
        self.position += len(bytes.value)

    def close(self):
        self.data.close()

    def flush(self):
        pass


class libreoffice_client(object):
    def __init__(self, port=DEFAULT_LIBREOFFICE_PORT):
        self._local_context = uno.getComponentContext()
        self._service_manager = self._local_context.ServiceManager
        resolver = self._service_manager.createInstanceWithContext("com.sun.star.bridge.UnoUrlResolver", self._local_context)
        try:
            context = resolver.resolve("uno:socket,host=localhost,port=%s;urp;StarOffice.ComponentContext" % port)
        except NoConnectException, exception:
            raise Exception, "Failed to connect to LibreOffice on port %s. %s\nIf you don't have a server then read README for 'OPTIONAL LIBRARIES' to see how to set one up." % (port, exception)
        self._desktop = context.ServiceManager.createInstanceWithContext("com.sun.star.frame.Desktop", context)

    def convert_by_stream(self, data, format=LIBREOFFICE_OPEN_DOCUMENT):
        input_stream = self._service_manager.createInstanceWithContext("com.sun.star.io.SequenceInputStream", self._local_context)
        data.seek(0)
        input_stream.initialize((uno.ByteSequence(data.read()),)) 
        document = self._desktop.loadComponentFromURL('private:stream', "_blank", 0, self._to_properties(InputStream=input_stream,ReadOnly=True))
        if not document:
            raise Exception, "Error making document"
        try:
            document.refresh()
        except AttributeError:
            pass
        output_stream = output_stream_wrapper()
        try:
            document.storeToURL('private:stream', self._to_properties(OutputStream=output_stream, FilterName=format))
        except Exception, e: #ignore any error, verify the output before complaining
            pass
        finally:
            document.close(True)
        if format == LIBREOFFICE_OPEN_DOCUMENT or format == LIBREOFFICE_PDF:
            doc_type = document_type.detect_document_type(output_stream.data)
            output_stream.data.seek(0)
            if format == LIBREOFFICE_OPEN_DOCUMENT and doc_type != document_type.types.oasis_open_document:
                raise docvert_exception.converter_unable_to_generate_open_document("Unable to generate OpenDocument, was detected as %s.\n\nAre you sure you tried to convert an office document? If so then it\nmight be a bug, so please contact http://docvert.org and we'll see\nif we can fix it. Thanks!" % doc_type)
            elif format == LIBREOFFICE_PDF and doc_type != document_type.types.pdf:
                raise docvert_exception.converter_unable_to_generate_pdf("Unable to generate PDF, was detected as %s. First 4 bytes = %s" % (doc_type, output_stream.data.read(4)))
        return output_stream.data

    def _to_properties(self, **args):
        props = []
        for key in args:
            prop = PropertyValue()
            prop.Name = key
            prop.Value = args[key]
            props.append(prop)
        return tuple(props)

def checkLibreOfficeStatus():
    try:
        libreoffice_client()
        return True
    except Exception:
        return False

def get_client():
    global client
    if client is None:
        client = libreoffice_client()
    return client

