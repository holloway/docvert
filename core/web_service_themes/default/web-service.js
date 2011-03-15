var docvert = {
    buffer: {"width":20, "height":50},
    resize_prefix_box: function(event){
        var iframe_element = $("iframe")
        var iframe_offset = iframe_element.offset()
        
        iframe_element.height( $(window).height() - iframe_offset.top - docvert.buffer.height).width($(window).width() - iframe_offset.left - docvert.buffer.width)
        iframe_element.css({"top":-iframe_element.height(), position:"relative"})
        iframe_element.animate({top:0}, "slow")
    },
    click_back: function(event){
        var iframe_element = $("iframe")
        iframe_element.animate({top: -(iframe_element.height() + (docvert.buffer.height * 3))}, "slow", function(){
            window.location.href = "index"
        })
        return false
    }
}

$(document).ready(function(){
    $(window).resize(docvert.resize_prefix_box).resize()
    $(".back-link a").click(docvert.click_back)
})
