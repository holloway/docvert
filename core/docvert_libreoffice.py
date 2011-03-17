# -*- coding: utf-8 -*-
from os.path import abspath
from os.path import isfile
from os.path import splitext
import sys
from StringIO import StringIO
import document_type
import docvert_exception

DEFAULT_LIBREOFFICE_PORT = 2002
LIBREOFFICE_OPEN_DOCUMENT = 'writer8'
LIBREOFFICE_PDF = 'writer_pdf_Export'
try:
    import uno
except ImportError:
    sys.path.append('/opt/libreoffice/program/')
    sys.path.append('/usr/lib/libreoffice/program/')
    sys.path.append('/usr/lib/openoffice.org/program/')
    sys.path.append('/usr/lib/openoffice.org2.0/program/')
    try:
        import uno
    except ImportError:
        sys.stderr.write("Error: Unable to find Python UNO libraries in %s. Exiting..." % sys.path)
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
            raise Exception, "Failed to connect to LibreOffice.org on port %s. %s" % (port, exception)
        self._desktop = context.ServiceManager.createInstanceWithContext("com.sun.star.frame.Desktop", context)

    def convert_by_stream(self, data, format=LIBREOFFICE_OPEN_DOCUMENT):
        input_stream = self._service_manager.createInstanceWithContext("com.sun.star.io.SequenceInputStream", self._local_context)
        #NOTE: Getting garbled characters ("###########") in your XML out of LibreOffice? Check that the data's file pointer is set to the start E.g. data.seek(0) 
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
            document.storeToURL('private:stream', self._to_properties(
                OutputStream=output_stream,
                FilterName=format))
        finally:
            document.close(True)
        if format == LIBREOFFICE_OPEN_DOCUMENT:
            doc_type = document_type.detect_document_type(output_stream.data)
            if doc_type != document_type.types.oasis_open_document:
                raise docvert_exception.converter_unable_to_generate_open_document()
        return output_stream.data

    def _to_properties(self, **args):
        props = []
        for key in args:
            prop = PropertyValue()
            prop.Name = key
            prop.Value = args[key]
            props.append(prop)
        return tuple(props)

