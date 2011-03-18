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
        <h1>Doc<span class="syllable">vert</span> <span class="version">5</span> <span class="slogan"><abbr title="Microsoft">MS</abbr>Word to Open Standards</span></h1>
        <h2>Tests <span id="run-all">(<a href="#run-all">run all</a>)</span></h2>
        <ul>
% for pipeline in tests:
            <li id="test-{{pipeline['id']}}"><a href="/web-service/tests/{{pipeline['id']}}"><span class="result testSummary">?</span>  {{pipeline['name']}}</a></li>
% end
        </ul>
    </body>
</html>
