# -*- coding: utf-8 -*-
import sys
import StringIO
import uuid
import os.path
try:
    import bottle
except ImportError:
    sys.path.append('./lib/bottle') 
    try:
        import bottle
    except ImportError:
        sys.stderr.write("Error: Unable to find Bottle libraries in %s. Exiting..." % sys.path)
        sys.exit(0)
import lib.bottlesession.bottlesession
bottle.debug(True)

import core.docvert
import core.docvert_storage
import core.docvert_exception

# START CONFIG
theme='default'
port=8080
# END CONFIG

theme_directory='./core/web_service_themes'
bottle.TEMPLATE_PATH.append('%s/%s' % (theme_directory, theme))

@bottle.route('/index', method='GET')
@bottle.route('/', method='GET')
@bottle.view('index')
def index():
    return core.docvert.get_all_pipelines()

@bottle.route('/static/:path#.*#', method='GET')
def static(path=''):
    return bottle.static_file(path, root=theme_directory)

@bottle.route('/lib/:path#.*#', method='GET')
def libstatic(path=None):
    return bottle.static_file(path, root='./lib')

@bottle.route('/web-service.php', method='POST') #for legacy support
@bottle.route('/web-service', method='POST')
@bottle.view('web-service')
def webservice():
    files = dict()
    first_document_id = None
    for key, item in bottle.request.files.iteritems():
        filename = item.filename
        unique = 1
        #print filename
        while files.has_key(filename):
            filename = item.filename + unique
            unique += 1
        if first_document_id is None:
            first_document_id = filename
        files[filename] = StringIO.StringIO(item.value)
    pipeline_id = bottle.request.POST.get('pipeline')
    auto_pipeline_id = bottle.request.POST.get('auto_pipeline')
    after_conversion = bottle.request.POST.get('after_conversion')
    urls = bottle.request.POST.get('upload_web[]')
    response = None
    try:
        response = core.docvert.process_conversion(files, urls, pipeline_id, "pipelines", auto_pipeline_id)
    except core.docvert_exception.debug_exception, exception:
        bottle.response.content_type = exception.content_type
        return exception.data
    if after_conversion == "zip":
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

@bottle.route('/tests', method='GET')
@bottle.view('tests')
def tests():
    if bottle.DEBUG is False:
        raise core.docvert_exception.tests_disabled("Sorry, but tests are only viewable in DEBUG mode.") #not that they'll be able to see the exception in debug mode. Natch.
    return core.docvert.get_all_pipelines()

@bottle.route('/web-service/tests/:test_id', method='GET')
def web_service_tests(test_id):
    if bottle.DEBUG is False:
        raise core.docvert_exception.tests_disabled("Sorry, but tests are only viewable in DEBUG mode.") #not that they'll be able to see the exception in debug mode. Natch.
    storage = core.docvert_storage.storage_memory_based()
    try:
        core.docvert.process_pipeline(None, test_id, "tests", None, storage)
    except core.docvert_exception.debug_exception, exception:
        bottle.response.content_type = exception.content_type
        return exception.data
    return bottle.json_dumps(storage.tests) #is this safe to use?

@bottle.route('/tests/', method='GET')
def tests_wrongdir():
    bottle.redirect('/tests')

bottle.run(host='localhost', port=port, quiet=False)


