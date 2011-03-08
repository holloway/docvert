# -*- coding: utf-8 -*-
import sys
import StringIO
try:
    import bottle
except ImportError:
    sys.path.append('./lib/bottle') 
    import bottle

bottle.debug(True)

import core.docvert

# START CONFIG
theme='default'
# END CONFIG

theme_directory='./core/web_service_themes'
bottle.TEMPLATE_PATH.append('%s/%s' % (theme_directory, theme))

@bottle.route('/', method='GET')
@bottle.view('index')
def index():
    pipelines = [{'id':'web standards','name':'Web Standards'},{'id':'blah','name':'Frank Enstein'}]
    auto_pipelines = [{'id':'blah','name':'Break up over Heading 1'},{'id':'blah','name':'Nothing (one long page)'}]
    return dict(pipelines=pipelines,auto_pipelines=auto_pipelines)

@bottle.route('/static/:path#.*#', method='GET')
def static(path=''):
    return bottle.static_file(path, root=theme_directory)

@bottle.route('/lib/:path#.*#', method='GET')
def libstatic(path=None):
    return bottle.static_file(path, root='./lib')

@bottle.route('/web-service', method='POST')
def webservice():
    files = dict()
    for key, item in bottle.request.files.iteritems():
        filename = item.filename
        unique = 1
        while files.has_key(filename):
            filename = item.filename + unique
            unique += 1
        files[filename] = StringIO.StringIO(item.value)
    pipeline = bottle.request.POST.get('pipeline')
    auto_pipeline = bottle.request.POST.get('auto_pipeline')
    response = core.docvert.process_conversion(files, pipeline, auto_pipeline)
    bottle.response.content_type = "text/xml"
    return response

@bottle.route('/favicon.ico', method='GET')
def favicon():
    return bottle.static_file('favicon.ico', root='%s/%s' % (theme_directory, theme))

bottle.run(host='localhost', port=8080, quiet=False)
