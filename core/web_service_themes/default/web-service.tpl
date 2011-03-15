<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>Docvert - Web Service</title>
        <link rel="stylesheet" type="text/css" href="static/default/screen.css">
        <script type="text/javascript" src="lib/jquery/jquery-1.5.min.js"></script>
        <script type="text/javascript" src="static/default/jquery.dropp.js"></script>
        <script type="text/javascript" src="static/default/web-service.js"></script>
    </head>
    <body class="web-service-page">
        <h1>Doc<span class="syllable">vert</span> <span class="version">5</span> <span class="slogan"><abbr title="Microsoft">MS</abbr>Word to Open Standards</span></h1>
        <p class="back-link"><a href="/index#slide-in">&larr;back</a></p>
        <ul id="conversion-tabs">
% for filename, conversion in conversions.iteritems():
         <li><a href="conversions/{{conversion_id}}/{{filename}}" title="{{filename}} via {{conversion['pipeline']}}/{{conversion['auto_pipeline']}}">{{filename}}</a></li>
% end
        </ul>
        <iframe id="preview" src="conversions/{{conversion_id}}/{{first_document_id}}/">
        </iframe>
    </body>
</html>
