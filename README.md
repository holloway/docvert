Docvert 5.1
=============

Released under the GPL3 see LICENCE

Web Service
-----------

    python ./docvert-web.py [-p PORT]

Requirements
------------

Python 2.6 with lxml, pdf2svg and rsvg.

(we'll support Python 3 when distributions of PyUNO support Python 3)

Optional Libraries
------------------

If you want to convert Microsoft Office files you'll need:

    LibreOffice or OpenOffice.org server (which can run 'headless')

    PyUNO (python-uno)

To set this up on DEBIAN/UBUNTU/MINT just run

    apt-get install docvert-libreoffice

or

    apt-get install docvert-openoffice.org

Alternatively, if you want to do it manually then run (change the path to your install of LibreOffice/OpenOffice.org)

    /usr/bin/soffice -headless -norestore -nologo -norestore -nofirststartwizard -accept="socket,port=2002;urp;"

This runs a single instance. If you want to run a pool of instances then try something like http://oodaemon.sourceforge.net/

Command Line
------------

    python ./docvert-cli.py

    usage: docvert-cli.py [-h] [--version] --pipeline PIPELINE
        [--response {auto,path,stdout}]
        [--autopipeline {Break up over Heading 1.default,Nothing one long page}]
        [--url URL] [--list-pipelines]
        [--pipelinetype {tests,auto_pipelines,pipelines}]
        infile [infile ...]

Community
---------

http://lists.catalyst.net.nz/mailman/listinfo/docvert



