var docvert = {
    click_test: function(event) {
        var list = $(event.target).parent()
        var sublist = list.find("ul")
        if(sublist.length == 0) {
            sublist = $("<ul/>")
        } else {
            sublist.empty()
        }
        list.append(sublist)
        $(list).find(".testSummary").removeClass("pass fail").addClass("result").text("?")
        sublist.html("<li>please wait...</li>").slideDown()
        jQuery.getJSON($(event.target).attr("href") + "?callback_id=" + list.attr("id"), function(data, textStatus, jqXHR){
            if(sublist.length != 1) {
                return alert("Can't find a sublist.")
            }
            sublist.slideUp(function(){
                var test_status = "pass"
                sublist.empty()
                $(data).each(function(key,value){
                    if(value.status == "fail") test_status = "fail"
                    var text = (value.status == "pass") ? "&#x2714;" : "&#x2718;"
                    var list_item = $('<li><span class="' + value.status + '">' + text + '</span>' + $('<div/>').text(value.message).html() + '</li>')
                    sublist.append(list_item)
                })
                sublist.slideDown()
                var text = (test_status == "pass") ? "&#x2714;" : "&#x2718;"
                sublist.parent().find(".testSummary").removeClass("result pass fail").addClass(test_status).html(text)
            })
        })
        return false
    },

    run_all: function(event) {
        $("ul a").click()
        return false
    }

}

$(document).ready(function(){
    $("ul a").click(docvert.click_test)
    $("#run-all a").click(docvert.run_all)
})

