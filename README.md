Docvert 5.1
=============

Converts Word Processor office files (e.g. .DOC files) to OpenDocument, DocBook, and structured HTML.


Web Service
-----------

    python ./docvert-web.py [-p PORT] [-H host]

Command Line
------------

    python ./docvert-cli.py

    usage: docvert-cli.py [-h] [--version] --pipeline PIPELINE
        [--response {auto,path,stdout}]
        [--autopipeline {Break up over Heading 1.default,Nothing one long page}]
        [--url URL]
        [--list-pipelines]
        [--pipelinetype {tests,auto_pipelines,pipelines}]
        infile [infile ...]

Community
---------

http://lists.catalyst.net.nz/mailman/listinfo/docvert

Requirements
------------

    Python 2.6 or 2.7 (we'll support Python 3 when it supports PyUNO)
    libreoffice
    python-uno
    python-lxml
    python-imaging
    pdf2svg
    librsvg2-2
    
Quickstart Guide
----------------

    sudo apt-get install libreoffice python-uno python-lxml python-imaging pdf2svg librsvg2-2

    /usr/bin/soffice --headless --norestore --nologo --norestore --nofirststartwizard --accept="socket,port=2002;urp;"

then in another terminal

    cd ~

    git clone git://github.com/holloway/docvert.git

    cd docvert

    python ./docvert-web.py

and browse to http://localhost:8080

A note on the LibreOffice Daemon
--------------------------------

If you want to convert Microsoft Office files you'll need to start a daemon:

    /usr/bin/soffice -headless -norestore -nologo -norestore -nofirststartwizard -accept="socket,port=2002;urp;"

This runs a single instance. If you want to run a pool of instances then try something like http://oodaemon.sourceforge.net/


LICENCE
-------
Released under the GPL3 see LICENCE


