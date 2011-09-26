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
    <body onunload="" class="index-page">
        <ul id="menu">
            <li><a href="tests">Tests</a></li>
            <li class="current"><a href="#index">Web Service</a></li>
        </ul>
        <h1>Doc<span class="syllable">vert</span> <span class="version">5.1</span> <span class="slogan"><abbr title="Microsoft">MS</abbr>Word to Open Standards</span></h1>
        <form method="post" action="web-service" enctype="multipart/form-data">
            <div id="page">
                <fieldset id="upload_fieldset">
                    <legend>Upload Documents</legend>
                    <div id="upload_documents">
                        <div id="upload_from_file" class="upload_button">
                            <label for="upload_file"><span>From File</span></label>
                            <input type="file" name="upload_file[]" id="upload_file" multiple="multiple">
                        </div>
                        <div id="upload_from_web" class="upload_button">
                            <label for="upload_web"><span>From Web</span></label>
                        </div>
                    </div>
                    <h2 class="upload_list">Documents to Convert</h2>
                    <ul id="upload_list">
                    </ul>
                </fieldset>
                <fieldset id="pipelines">
                    <legend>Theme (<abbr title="Extensible Markup Language">XML</abbr> Pipeline)</legend>
                    <select name="pipeline" id="pipeline">
% for pipeline in sorted(pipelines):
                        <option value="{{pipeline['id']}}">{{pipeline['name']}}</option>
% end
                    </select>
                </fieldset>
                <fieldset id="autopipelines">
                    <legend>
                        <input type="hidden" name="break_up_pages_ui_version" id="break_up_pages_ui_version" value="2">
                        <label for="break_up_pages">Break over multiple pages? </label><input type="checkbox" name="break_up_pages" id="break_up_pages"/>
                    </legend>
                    <div id="autopipelines_options">
                        <p class="break_pages_note"><span>Please note that some pipelines don't support multiple pages.</span></p>
                        <select name="autopipeline" id="autopipeline">
% for auto_pipeline in auto_pipelines:
                            <option value="{{auto_pipeline['id']}}">{{auto_pipeline['name']}}</option>
% end
                        </select>
                    </div>
                </fieldset>
                <div id="upload_from_web_dialog">
                    <input type="text" name="upload_web[]" id="upload_web">
                </div>
                <fieldset id="advanced">
                    <legend><a href="#advanced">Advanced <span class="showHide">&#9654;</span></a></legend>
                    <div class="inner">
                         <p id="afterconversion">
                            <label for="after_conversion_preview"><input type="radio" id="after_conversion_preview" name="after_conversion" value="preview" checked="checked">Preview conversion</label> &nbsp;
                            <label for="after_conversion_zip"><input type="radio" id="after_conversion_zip" name="after_conversion" value="zip">Download .ZIP</label>
                        </p>
                    </div>
                </fieldset>
                <div id="submit_error">
                    <span>Please choose a file or web <abbr title="uniform resource locator">URL</abbr> to convert</span>
                </div>
                <div id="button_tray">
                    <input type="submit" value="Submit" id="upload_submit">
                </div>
            </div>
            <div id="libreOfficeStatus" class="libreOfficeStatus_{{libreOfficeStatus}}">LibreOffice <span></span></div>
        </form>
        <div id="usageNote">
            <h2>Dear programmers,</h2>
            <p>this form sends files via HTTP POST so do the same in your software to build upon this web service.</p>
        </div>
    </body>
</html>
