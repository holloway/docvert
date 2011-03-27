#!/usr/bin/env python2.6
# -*- coding: utf-8 -*-
import sys
import StringIO
import uuid
import os.path
import argparse
import core.docvert
import core.docvert_storage
import core.docvert_exception

version = core.docvert.version
pipeline_types = core.docvert.get_all_pipelines()
auto_pipelines = []
default_auto_pipeline = None
for auto_pipeline in pipeline_types['auto_pipelines']:
    auto_pipelines.append(auto_pipeline["id"])
    if auto_pipeline["id"].endswith(".default"):
        default_auto_pipeline = auto_pipeline["id"]

class PrintPipelines(argparse.Action):
    def __call__(self, parser, namespace, values, option_string=None):
        print "List of all pipelines\n---------------------"
        for pipeline_type, pipelines in pipeline_types.iteritems():
            print "type: %s" % pipeline_type
            for pipeline in pipelines:
                print "      - %s" % pipeline['id']
            print ""
        exit()

parser = argparse.ArgumentParser(description='Converts Office files to OpenDocument, DocBook and HTML.')
parser.add_argument('--version', '-v', action='version', version='Docvert %s' % version)
parser.add_argument('--infile', type=file, help='Path or Stdin of Office file to convert', default=sys.stdin, nargs='+')
parser.add_argument('--pipeline', '-p', help='Pipeline you wish to use.', required=True)
parser.add_argument('--response', '-r', help='Format of conversion response.', default='auto', choices=['auto','path','stdout'])
parser.add_argument('--autopipeline', '-a', help='AutoPipeline to use (when your pipeline requires it).', default=default_auto_pipeline, choices=auto_pipelines)
parser.add_argument('--url', '-u', help='URL to download and convert. Must be an Office file.')
parser.add_argument('--list-pipelines', '-l', action=PrintPipelines, help='List all pipeline types', nargs=0)
parser.add_argument('--pipelinetype', '-t', help='Pipeline type you wish to use.', default='pipelines', choices=pipeline_types.keys())

args = parser.parse_args() #stops here if there were no args, or if they asked for --help

process_commands(args['infile'], args['pipeline'], args['pipelinetype'], args['autopipeline'], args['response'], args['url'])

def process_commands(filedata, pipeline_id, pipeline_type, auto_pipeline_id, after_conversion, url):
    files = dict()
    first_document_id = None
    docvert_4_default = '.default'
    if auto_pipeline_id and auto_pipeline_id.endswith(docvert_4_default):
        auto_pipeline_id = auto_pipeline_id[0:-len(docvert_4_default)]
    after_conversion = bottle.request.POST.get('afterconversion')
    urls = bottle.request.POST.get('upload_web[]')
    response = None
    try:
        response = core.docvert.process_conversion(files, urls, pipeline_id, "pipelines", auto_pipeline_id)
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



