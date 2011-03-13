<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>Docvert - Web Service</title>
        <link rel="stylesheet" type="text/css" href="static/default/screen.css">
        <script type="text/javascript" src="lib/jquery/jquery-1.5.min.js"></script>
        <script type="text/javascript" src="static/default/jquery.dropp.js"></script>
        <script type="text/javascript" src="static/default/index.js"></script>
    </head>
    <body onunload="">
        <h1>Doc<span class="syllable">vert</span> <span class="version">5</span> <span class="slogan"><abbr title="Microsoft">MS</abbr>Word to Open Standards</span></h1>
        <ul>
{{conversion_id}}
% for key, conversion in conversions.storage.iteritems():
         <li><a href="#{{key}}" title="{{key}}">{{key}}</a></li>
% end
        </ul>
        <iframe id="preview">
        </iframe>
    </body>
</html>
