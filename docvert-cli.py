#!/usr/bin/env python2.6
# -*- coding: utf-8 -*-
import sys
import StringIO
import uuid
import os.path
import copy
import argparse
import tempfile
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

parser = argparse.ArgumentParser(description='Converts Office files to OpenDocument, DocBook and HTML.', epilog='E.g.: ./docvert-cli.py doc/sample/sample-document.doc -p="web standards"')
parser.add_argument('--version', '-v', action='version', version='Docvert %s' % version)
parser.add_argument('infile', type=file, help='Path or Stdin of Office file to convert', default=sys.stdin, nargs='+')
parser.add_argument('--pipeline', '-p', help='Pipeline you wish to use.', required=True)
parser.add_argument('--response', '-r', help='Format of ZIP conversion response.', default='auto', choices=['auto','path','stdout'])
parser.add_argument('--autopipeline', '-a', help='AutoPipeline to use (when your pipeline requires it).', default=default_auto_pipeline, choices=auto_pipelines)
parser.add_argument('--url', '-u', help='URL to download and convert. Must be an Office file.')
parser.add_argument('--list-pipelines', '-l', action=PrintPipelines, help='List all pipeline types', nargs=0)
parser.add_argument('--pipelinetype', '-t', help='Pipeline type you wish to use.', default='pipelines', choices=pipeline_types.keys())

args = parser.parse_args() #stops here if there were no args or if they asked for --help

def process_commands(filesdata, pipeline_id, pipeline_type, auto_pipeline_id, after_conversion, url):
    docvert_4_default = '.default'
    if auto_pipeline_id and auto_pipeline_id.endswith(docvert_4_default):
        auto_pipeline_id = auto_pipeline_id[0:-len(docvert_4_default)]
    files = dict()
    file_index = 1
    for filedata in filesdata:
        files['document-%i.doc' % file_index] = filedata
        file_index += 1
    urls = list()
    if url != None:
        urls.append(url)
    try:
        response = core.docvert.process_conversion(files, urls, pipeline_id, pipeline_type, auto_pipeline_id)
    except core.docvert_exception.debug_exception, exception:
        print >> sys.stderr, "%s: %s" % (exception, exception.data)
    #TODO: when after_conversion="auto"
    if after_conversion == "stdout":
        print >> sys.stdout, response.to_zip().getvalue()
        exit()
    os_handle, zip_path = tempfile.mkstemp()
    zip_handler = open(zip_path, 'w')
    zip_handler.write(response.to_zip().getvalue())
    zip_handler.close()
    os.rename(zip_path, "%s.zip" % zip_path)
    print "Success! ZIP conversion at: %s.zip" % zip_path


   
process_commands(args.infile, args.pipeline, args.pipelinetype, args.autopipeline, args.response, args.url)

