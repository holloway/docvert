#!/usr/bin/env python2.6
# -*- coding: utf-8 -*-
import sys
import StringIO
import uuid
import os.path
import socket
import optparse

docvert_root = os.path.dirname(os.path.abspath(__file__))
inbuilt_bottle_path = os.path.join(docvert_root, 'lib/bottle')
try:
    import bottle
    if not hasattr(bottle, 'static_file'):
        message = "Notice: Old version of Bottle at %s, instead using bundled version at %s%sbottle.py" % (bottle.__file__, inbuilt_bottle_path, os.sep)
        print message
        raise ImportError, message
except ImportError, exception:
    try:
        sys.path.insert(0, inbuilt_bottle_path)
        try:
            reload(bottle)
        except NameError:
            import bottle
    except ImportError:
        sys.stderr.write("Error: Unable to find Bottle libraries in %s. Exiting...\n" % sys.path)
        sys.exit(0)

import lib.bottlesession.bottlesession
bottle.debug(True)

import core.docvert
import core.docvert_storage
import core.docvert_exception

# START DEFAULT CONFIG
theme='default'
port=8080
# END CONFIG
parser = optparse.OptionParser()
parser.add_option("-p", "--port", dest="port", help="Port to run on", type="int")
(options, args) = parser.parse_args()
if options.port:
    port = options.port

theme_directory='%s/core/web_service_themes' % docvert_root
bottle.TEMPLATE_PATH.append('%s/%s' % (theme_directory, theme))

@bottle.route('/index', method='GET')
@bottle.route('/', method='GET')
@bottle.view('index')
def index():
    return dict(core.docvert.get_all_pipelines().items() + {"libreOfficeStatus": core.docvert_libreoffice.checkLibreOfficeStatus()}.items() )

@bottle.route('/static/:path#.*#', method='GET')
def static(path=''):
    return bottle.static_file(path, root=theme_directory)

@bottle.route('/lib/:path#.*#', method='GET')
def libstatic(path=None):
    return bottle.static_file(path, root='%s/lib' % docvert_root)

@bottle.route('/web-service.php', method='POST') #for legacy support
@bottle.route('/web-service', method='POST')
@bottle.view('web-service')
def webservice():
    files = dict()
    first_document_id = None
    for key, item in bottle.request.files.iteritems():
        items = bottle.request.files.getall(key)
        for field_storage in items:
            filename = field_storage.filename
            unique = 1
            if files.has_key(filename) and files[filename].getvalue() == field_storage.value:
                continue
            while files.has_key(filename):
                filename = field_storage.filename + str(unique)
                unique += 1
            try:
                filename = filename.decode("utf-8")
            except UnicodeDecodeException, exception:
                pass
            if first_document_id is None:
                first_document_id = filename
            files[filename] = StringIO.StringIO(field_storage.value)
    pipeline_id = bottle.request.POST.get('pipeline')
    auto_pipeline_id = bottle.request.POST.get('autopipeline')
    docvert_4_default = '.default'
    if auto_pipeline_id and auto_pipeline_id.endswith(docvert_4_default):
        auto_pipeline_id = auto_pipeline_id[0:-len(docvert_4_default)]
    after_conversion = bottle.request.POST.get('afterconversion')
    urls = bottle.request.POST.get('upload_web[]')
    response = None
    try:
        response = core.docvert.process_conversion(files, urls, pipeline_id, 'pipelines', auto_pipeline_id)
    except core.docvert_exception.debug_exception, exception:
        bottle.response.content_type = exception.content_type
        return exception.data
    if after_conversion == "downloadZip":
        bottle.response.content_type = 'application/zip'
        return response.to_zip().getvalue()
    pipeline_summary = "%s (%s)" % (pipeline_id, auto_pipeline_id)
    session_manager = lib.bottlesession.bottlesession.PickleSession()
    session = session_manager.get_session()
    conversion_id = "%s" % uuid.uuid4()
    session[conversion_id] = response
    session_manager.save(session)
    conversions_tabs = dict()
    for filename in files.keys():
        thumbnail_path = "%s/thumbnail.png" % filename
        if response.has_key(thumbnail_path):
            thumbnail_path = None
        conversions_tabs[filename] = dict(pipeline=pipeline_id, auto_pipeline=auto_pipeline_id, thumbnail_path=thumbnail_path)
    return dict(conversions=conversions_tabs, conversion_id=conversion_id, first_document_id=first_document_id)

@bottle.route('/favicon.ico', method='GET')
def favicon():
    return bottle.static_file('favicon.ico', root='%s/%s' % (theme_directory, theme))

@bottle.route('/conversions/:conversion_id/:path#.*#')
def conversion_static_file(conversion_id, path):
    session_manager = lib.bottlesession.bottlesession.PickleSession()
    session = session_manager.get_session()
    if not session.has_key(conversion_id): # They don't have authorisation
        raise bottle.HTTPError(code=404)
    try:
        path = path.decode("utf-8")
    except UnicodeDecodeException, exception:
        pass
    if not session[conversion_id].has_key(path): # They have authorisation but that exact path doesn't exist, try fallbacks
        fallbacks = ["index.html", "index.htm", "index.xml", "index.php", "default.htm", "default.html", "index.asp", "default.aspx", "index.aspx", "default.aspx"]
        valid_fallback_path = None
        separator = "/"
        if path.endswith("/"):
            separator = ""
        for fallback in fallbacks:
            fallback_path = path+separator+fallback
            if session[conversion_id].has_key(fallback_path):
                valid_fallback_path = fallback_path
                break
        if valid_fallback_path is None:
            raise bottle.HTTPError(code=404)
        path = valid_fallback_path
    filetypes = {".xml":"text/xml", ".html":"text/html", ".xhtml":"text/html", ".htm":"text/html", ".svg":"image/svg+xml", ".png":"image/png", ".gif":"image/gif", ".bmp":"image/x-ms-bmp", ".jpg":"image/jpeg", ".jpe":"image/jpeg", ".jpeg":"image/jpeg", ".css":"text/css", ".js":"text/javascript"}
    extension = os.path.splitext(path)[1]
    if filetypes.has_key(extension):
        bottle.response.content_type = filetypes[extension]
    else:
        bottle.response.content_type = "plain/text"
    return session[conversion_id][path]

@bottle.route('/conversions-zip/:conversion_id')
def conversion_zip(conversion_id):
    session_manager = lib.bottlesession.bottlesession.PickleSession()
    session = session_manager.get_session()
    if not session.has_key(conversion_id): # They don't have authorisation
        raise bottle.HTTPError(code=404)
    bottle.response.content_type = 'application/zip'
    return session[conversion_id].to_zip().getvalue()

@bottle.route('/libreoffice-status', method='GET')
def libreoffice_status():
    return bottle.json_dumps( {"libreoffice-status":core.docvert_libreoffice.checkLibreOfficeStatus()} )


@bottle.route('/tests', method='GET')
@bottle.view('tests')
def tests():
    return core.docvert.get_all_pipelines()

@bottle.route('/web-service/tests/:test_id', method='GET')
def web_service_tests(test_id):
    suppress_error = bottle.request.GET.get('suppress_error') == "true"
    storage = core.docvert_storage.storage_memory_based()
    error_message = None
    if suppress_error:
        try:
            core.docvert.process_pipeline(None, test_id, "tests", None, storage)
        except Exception, exception:
            bottle.response.content_type = "text/plain"
            class_name = "%s" % type(exception).__name__
            return bottle.json_dumps([{"status":"fail", "message": "Unable to run tests due to exception. <%s> %s" % (class_name, exception)}])
    else:
        try:
            core.docvert.process_pipeline(None, test_id, "tests", None, storage)
        except (core.docvert_exception.debug_exception, core.docvert_exception.debug_xml_exception), exception:
            bottle.response.content_type = exception.content_type
            return exception.data
    return bottle.json_dumps(storage.tests)

@bottle.route('/tests/', method='GET')
def tests_wrongdir():
    bottle.redirect('/tests')

try:
    bottle.run(host='localhost', port=port, quiet=False)
except socket.error, e:
    if 'address already in use' in str(e).lower():
        print 'ERROR: localhost:%i already in use.\nTry another port? Use command line parameter -p PORT' % port
    else:
        raise


