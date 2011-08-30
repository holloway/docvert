if(history) history.navigationMode = 'compatible';

if(location && location.hash.toString().indexOf("back-reload") != -1){ //see http://stackoverflow.com/questions/158319/cross-browser-onload-event-and-the-back-button
    window.location.href = (window.location.href.toString().indexOf("#") != -1) ? window.location.href.toString().substring(0, window.location.href.toString().indexOf("#")) : window.location.href.toString()
}

var docvert = {
    slide_in: function(){
        if(location && location.hash.toString().indexOf("slide-in") != -1){
            location.hash = ""
            var form_element = $("form")
            form_element.css({"top":-form_element.height(), position:"relative"})
            form_element.animate({top:0}, "slow")
        }
    },

    upload_file_change: function(event){
        $(event.target).parent().append($(event.target).clone())
        var text = $(event.target).val()
        var full_text = ""
        if(text.length > 25) {
            full_text = text
            text = text.substring(0,15) + "\u2026" + text.substring(text.length-10)
        }
        var list_item = $("<li>").attr("title",full_text).append($(event.target).attr("id","").css("display","none")).text(text).append(' <a href="#delete-item" class="delete" title="Remove upload item">&times</a>').hide()
        $("#upload_list").append(list_item)
        list_item.slideDown()
        $("#upload_submit").removeClass("disabled").addClass("enabled")
        $("#submit_error").slideUp()
        $(".upload_list").slideDown()
    },

    upload_file_delete: function(event){
        var container = $(event.target).parent()
        if(container.parent().children().length === 1) {
            $("#upload_submit").addClass("disabled").removeClass("enabled")
            $(".upload_list").slideUp()
        }
        container.slideUp('slow',function(){
            container.remove()
        })
        return false
    },

    upload_file_mouseover: function(event) {
        $("#upload_from_file").addClass("upload_button_hover")
    },

    upload_file_mouseout: function(event) {
        $("#upload_from_file").removeClass("upload_button_hover")
    },

    reveal_upload_web_dialog: function(event){
        var sender = $(event.target)
        sender_offset = sender.offset()
        $("#upload_from_web_dialog").show().css({"position":"absolute","left":sender_offset.left+"px","top":(sender_offset.top+sender.height())+"px"})
        $("#upload_from_web_dialog input").val("http://\u2026").select()
    },

    is_url: function(value){
        //an intentionally rather liberal url detector
        var url_pattern = /^(ftp|http|https):\/\/.*?\//i
        return url_pattern.test(value)
    },

    hide_upload_web_dialog: function(event){
        $("#upload_from_web_dialog").hide()
        var url = $("#upload_from_web_dialog input").val()
        if(docvert.is_url(url)) {
            docvert.upload_file_change(event)
        }
    },

    replace_select: function(select, width){
    },

    check_submit: function(event){
        docvert.hide_upload_web_dialog()
        var should_submit = ($("#upload_list li").length > 0)
        if(!should_submit) {
            $("#submit_error").slideDown().find("span").animate({"marginLeft": "50px"}, function(){
                $("#submit_error span").animate({"marginLeft": "-50px"}, function(){
                    $("#submit_error span").animate({"marginLeft": "50px"}, function(){
                        $("#submit_error").slideDown().find("span").animate({"marginLeft": "-50px"}, function(){
                            $("#submit_error").slideDown().find("span").animate({"marginLeft": "0px"})
                        })
                    })
                })
            })
            return false
        }
        if($("#after_conversion_preview").is(":checked")){
            location.hash = "back-reload" //see http://stackoverflow.com/questions/158319/cross-browser-onload-event-and-the-back-button
            var form_element = $("form")
            form_element.css({"position":"relative"}).animate({"top": -(form_element.offset().top + form_element.height() + 50)},"slow", function(){
                $("form").submit()
            })
            return false
        }
    },

    click_advanced: function(){
        var inner = $(this).parents("fieldset").find(".inner")
        if(inner.hasClass("closed")) {
            $("span", this).html("&#9660;")
            inner.removeClass("closed").slideDown()
        } else {
            $("span", this).html("&#9654;")
            inner.addClass("closed").slideUp()
        }
        return false
    },

    keydown: function(event){
        var escape_key = 27
        if (event.keyCode == escape_key) {
            $("#upload_from_web_dialog").hide()
        }
    },

    reset_check_libreoffice_status: function(){
        docvert.number_of_libreoffice_checks_remaining = 10
    },

    check_libreoffice_status: function(event) {
        $.ajax({
            url: '/libreoffice-status',
            dataType: 'json',
            success: function(data, textStatus, jqXHR){
                if(data['libreoffice-status']) {
                    $("#libreOfficeStatus").removeClass("libreOfficeStatus_False").addClass("libreOfficeStatus_True")
                } else {
                    $("#libreOfficeStatus").removeClass("libreOfficeStatus_True").addClass("libreOfficeStatus_False")
                }
                docvert.number_of_libreoffice_checks_remaining -= 1
                if(docvert.number_of_libreoffice_checks_remaining > 0){
                    docvert.libreoffice_status_timer = setTimeout(docvert.check_libreoffice_status, 1000)
                }
                //$("#advanced").text(docvert.number_of_libreoffice_checks_remaining)
            }
        })
    }
}

$(document).ready(function(){
    docvert.slide_in()
    $("#upload_submit").addClass("disabled").removeClass("enabled")
    $(".upload_list").hide()
    $(".delete").live("click", docvert.upload_file_delete)
    var upload_file = $("#upload_file")
    upload_file.change(docvert.upload_file_change)
               .mouseover(docvert.upload_file_mouseover)
               .mouseout(docvert.upload_file_mouseout)
    $("#upload_documents label").css({
        "width":upload_file.width() + "px",
        "height": upload_file.height() + "px",
        "margin-right": - upload_file.width() + "px"})
    $("#upload_from_web label").click(docvert.reveal_upload_web_dialog)
    $("#upload_from_web_dialog").hide()
    $("#upload_from_web_dialog input").blur(docvert.hide_upload_web_dialog)
    $("fieldset,#button_tray").width((upload_file.width() * 2) + 30)
    $("#page,form").width((upload_file.width() * 2) + 53)
    $("#upload_submit").click(docvert.check_submit)
    $("select").dropp()
    $("#advanced .inner").addClass("closed").hide()
    $("#advanced legend a").click(docvert.click_advanced)
    docvert.reset_check_libreoffice_status()
    docvert.libreoffice_status_timer = setTimeout(docvert.check_libreoffice_status, 1000)
    $("*").live("focus click", docvert.reset_check_libreoffice_status)
    $("#break_up_pages").change(function(){
        if($(this).is(":checked")){
            $("#autopipelines_options").slideDown().parent()
        } else {
            $("#autopipelines_options").slideUp()
        }
        $("#autopipeline").nextAll(".dropp_dropdown_list").width(upload_file.width() * 2 + 30).css("clear","both")
    }).change()
}).keydown(docvert.keydown)

