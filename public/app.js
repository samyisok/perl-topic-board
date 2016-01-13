$(document).ready(function(){
    $("blockquote").map(function(){
            console.log($(this));
            var text = $(this).html()
            $(this).html(make_Ref(text))
    });
});


function make_Ref(text) {
   return text.replace(/&gt;&gt;((\w+\/|)(\d+\/|)\d+)/g,"<a onclick='focuspost($1)' data-ref='$1' href='#$1' class='msg_ref'>$&</a>");
}

/*refactor later*/
function insert(text)
{   
    var textform = $("form").find("textarea");
    var caretPos = textform.prop("selectionStart");
    var tmp_text = textform.val();
    textform.val(tmp_text.substring(0, caretPos) + text + tmp_text.substring(caretPos));
    textform.focus();
}



function focuspost(id){
    var postwrap = $("#post-"+id);
    $(".hiclass").removeClass("hiclass");
    postwrap.addClass("hiclass");
    $(window).scrollTop(postwrap.offset().top);
    postwrap.focus();
}
