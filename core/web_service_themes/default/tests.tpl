<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
        <title>Docvert - Tests</title>
        <link rel="stylesheet" type="text/css" href="static/default/screen.css">
        <script type="text/javascript" src="lib/jquery/jquery-1.5.min.js"></script>
        <script type="text/javascript" src="static/default/jquery.dropp.js"></script>
        <script type="text/javascript" src="static/default/tests.js"></script>
    </head>
    <body onunload="" class="tests-page">
        <ul id="menu">
            <li class="current"><a href="#tests">Tests</a></li>
            <li><a href="index">Web Service</a></li>
        </ul>
        <h1><a href="index">Doc<span class="syllable">vert</span> <span class="version">5.1</span> <span class="slogan"><abbr title="Microsoft">MS</abbr>Word to Open Standards</span></a></h1>
        <h2>Tests <span id="run-all">(<a href="#run-all">run all</a>)</span></h2>
        <ul class="tests">
% for pipeline in tests:
            <li id="test-{{pipeline['id']}}"><a href="/web-service/tests/{{pipeline['id']}}" title="Perform {{pipeline['name']}} tests"><span class="result testSummary">?</span>  {{pipeline['name']}} <span class="ratio"></span></a></li>
% end
        </ul>
    </body>
</html>
