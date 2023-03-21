function languagePickerGrid(gitbook, elem, maxColumns, langData) {
	var CurAddr = location.href.substr(gitbook.state.root.length);
	var sharp = CurAddr.indexOf("#");
	var CurAddrNoAnchor = (sharp == -1)? CurAddr : CurAddr.substr(0, sharp);

	var table = $("<table>");
	var ins = 0;
	var maxRows = Math.ceil(langData.length / maxColumns);
	for (var i = 0; i < maxRows; i++) {
		var r = $("<tr>");
		for (var ii = 0; (i * maxColumns + ii < langData.length) && (ii < maxColumns); ii++) {
			var c = $("<td>");
			var l = $("<a>");
			l.attr("href", gitbook.state.bookRoot.replace(/([^\/])$/, "$1/") + langData[ins][0] +"/"+ CurAddrNoAnchor);
			l.attr("data-lang", langData[ins][0]);
			if (langData[ins][0] == gitbook.state.innerLanguage) l.addClass("current");
			l.html(langData[ins][1]);
			c.append(l);
			r.append(c);
			ins++;
		}
		table.append(r);
	}
	elem.append(table);
}
function parseLanguages(gitbook, elem, maxColumns, cb) {
	if (location.protocol == "file:") {
		var langData = [];
		langData.push(["en", "English"]);
		languagePickerGrid(gitbook, elem, maxColumns, langData);
		cb(elem);
	}
	else {
		$.get(gitbook.state.bookRoot +"index.html", function(data) {
			var list = data.match(/<ul class=\"languages\">([\s\S]+?)<\/ul>/);
			if (list) {
				var langData = [];
				list[1].replace(/<a href=\"([^\/]+)[^>]+>(.+?)<\/a>/g, function(a, b, c) {
					langData.push([b, c]);
				});
				languagePickerGrid(gitbook, elem, maxColumns, langData);
				cb(elem);
			}
		}, "html");
	}
}

require(["gitbook", "jQuery"], function(gitbook, $) {
	gitbook.events.bind("start", function(e, config) {
		var opts = config["language-picker"];

		gitbook.toolbar.createButton({
            icon: "fa fa-globe",
            label: "Change language",
			className: "language-picker",
			dropdown: []
        });

		$(function() {
			var DDMenu_selector = ".language-picker .dropdown-menu";
			$(document).one("click", ".language-picker .btn", function(e) {
				parseLanguages(gitbook, $(DDMenu_selector), opts["grid-columns"], function(elem) {
					elem.addClass("language-picker-grid");
					elem.trigger("parsedContent");
				});
			});
			/*$(document).on("parsedContent", DDMenu_selector, function() {
				alert("ready");
			});*/
		});
	});
});