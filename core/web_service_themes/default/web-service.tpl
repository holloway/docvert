% from urllib import quote
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
        <ul id="menu">
            <li><a href="tests">Tests</a></li>
            <li><a href="#index">Web Service</a></li>
        </ul>
        <h1>Doc<span class="syllable">vert</span> <span class="version">5.1</span> <span class="slogan"><abbr title="Microsoft">MS</abbr>Word to Open Standards</span></h1>
        <ul id="conversion-navigation-tabs">
            <li class="back-link"><a href="/index#slide-in">&#x25C2; back</a></li>
            <li class="zip-download"><a href="conversions-zip/{{conversion_id}}">Download ZIP</a></li>
        </ul>
        <ul id="conversion-tabs">
% for filename, conversion in conversions.iteritems():
            <li><a href="conversions/{{conversion_id}}/{{filename}}/" title="{{filename}} via {{conversion['pipeline']}}/{{conversion['auto_pipeline']}}" target="preview">{{conversion['friendly_name']}}</a></li>
% end
        </ul>
        <iframe id="preview" name="preview" src="{{ quote(first_document_url) }}">
        </iframe>
    </body>
</html>
