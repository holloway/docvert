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
        $.ajax({
            url: $(event.target).attr("href") + '?suppress_error=true',
            dataType: 'json',
            error: docvert.error,
            success: function(data, textStatus, jqXHR){
                if(sublist.length != 1) {
                    return alert("Can't find a sublist.")
                }
                sublist.slideUp(function(){
                    sublist.empty()
                    var test_count = {"pass":0,"fail":0}
                    var list_items_pass = "";
                    var list_items_fail = "";
                    $(data).each(function(key,value){
                        var text;
                        if(value.status == "fail") {
                            test_count.fail++
                            text = "&#x2718;";
                            list_items_fail += $('<li><span class="' + value.status + '">' + text + '</span>' + $('<div/>').text(value.message).html() + '</li>').wrap("<div/>").parent().html()
                        } else {
                            test_count.pass++
                            text = "&#x2714;";
                            list_items_pass += $('<li><span class="' + value.status + '">' + text + '</span>' + $('<div/>').text(value.message).html() + '</li>').wrap("<div/>").parent().html()
                        }
                    })
                    sublist.append(list_items_fail + list_items_pass)
                    var maximum_rows = 6
                    if(test_count.fail + test_count.pass > maximum_rows) {
                        sublist.css("height","0px").show().animate({"display":"block","height":(maximum_rows * 20)+"px"})
                    } else {
                        sublist.slideDown()
                    }
                    var test_status = (test_count.fail > 0) ? "fail" : "pass"
                    var text = (test_status == "pass") ? "&#x2714;" : "&#x2718;"
                    sublist.parent().find(".testSummary").removeClass("result pass fail").addClass(test_status).html(text).attr("title", test_count.pass + " pass, " + test_count.fail + " fail")
                })
            }
        })  
        return false
    },

    error: function(){
        alert("Unable to make AJAX request")
    },

    run_all: function(event) {
        $("ul.tests a").click()
        return false
    }

}

$(document).ready(function(){
    $("ul.tests a").click(docvert.click_test)
    $("#run-all a").click(docvert.run_all)
})

