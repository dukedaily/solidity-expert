
require(["gitbook"], function(gitbook) {

    gitbook.events.bind("page.change", function() {

        var h2_list = document.body.querySelectorAll(".page-wrapper h2");

        if(!h2_list.length) return false;

        var html = '<span class="title">Outlines&nbsp;&nbsp;<label class="arrow">\u25b2</label></span><div id="outline_block">';

        for(var i=0;i<h2_list.length;i++){
            var item = h2_list[i];
            html += '<a href="#' + item.id + '">' + item.innerHTML + '</a>';
        }

        html += '</div>';

        var outline = document.createElement("div");

        outline.id = "outline_id";
        outline.innerHTML = html;
        outline.className = "outline";

        document.body.querySelector(".page-wrapper").appendChild(outline);

        document.querySelector("#outline_id .title .arrow").onclick = function(){

            var dom = document.getElementById("outline_block");

            if(dom.style.display != "none")
                dom.style.display = "none";
            else
                dom.style.display = "block";
        }

    }); /* end of gitbook.events.bind("page.change", function() */

}); /* end of require(["gitbook"], function(gitbook) { */
