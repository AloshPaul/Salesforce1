$(document).ready(function() {

	var headerHeight = $(".header").height();

	// menu
	$(".menu li.withSub").hover(
		function() {
			if(screen.width > 767) { // for desktop and tablet view
				var li = $(this);
				var submenu = $("> .submenu", li);

				var lv1 = li;
				if(!li.hasClass("lv1")) { // sub level
					var parents = li.parentsUntil("li.lv1");
					lv1 = $(parents[parents.length-1]);
					submenu.css({
						top: li.offset().top - headerHeight - 41,
						left: Math.max(lv1.width(), li.parent().width())
					});
					submenu.css("width", lv1.width()+10).show();
				}
				else { // level 1
					submenu.css("width", lv1.width()).show();
				}
			}
		},
		function() {
			if(screen.width > 767) {
				var li = $(this);
				$("> .submenu", li).hide();
			}
		}
	);
	$(".menuWrapper .phoneFirstMenu").click(function() {
		var a = $(this);
		if(a.hasClass("expanded")) {
			$(".menuWrapper > ul:visible").slideUp(function() {
				$(".menuWrapper > ul").not(".menu").remove();
			});
			a.removeClass("expanded");
		}
		else {
			$("ul.menu").slideDown();
			a.addClass("expanded");
		}
	});
	$(".menuWrapper li.withSub > a").live("click", function() {
		if($(".phoneFirstMenu:visible").length > 0) {
			var href = $(this).attr("href");
			$(this).attr("href","javascript:void(0)");
			var li = $(this).parent();
			var ul = li.parent();
			var submenu = $("> .submenu", li);
			$(".lv2").css('padding-left','20px');
			var backNode = "<li class='back lv2'><a href='javascript:;'><span class='arrow'></span>BACK</a></li>";
			backNode += "<li class='teamLink lv2'><a href=\'" + href + "\'>" + $(this).text().toUpperCase() + "</a></li>"
			ul.fadeOut(function() {
				submenu = submenu.clone();
				$(".submenu", submenu).hide();
				submenu.hide().prepend(backNode)
					   .appendTo(ul.parent()).animate({width: 'toggle'});
			});
		}
	});
	
	$(".menuWrapper li.back > a").live("click", function() {
		if($(".phoneFirstMenu").css("display") === 'none') return false;
		var li = $(this).parent();
		var ul = li.parent();
		var last = ul.prev();
		$(".back").css('padding-left','0px');
		$(".teamLink").css('padding-left','0px');
		ul.fadeOut(function() {
			$(this).remove();
			last.animate({width: 'toggle'});
		});
	});

	/* side dropdown menu */
	$(".side .dropdownMenu.expanded > a").live("click", function() {
		var menu = $(this).parent();
		$("ul", menu).slideUp("fast", function() {
			menu.removeClass("expanded").addClass("collapsed");
		});
	});
	$(".side .dropdownMenu.collapsed > a").live("click", function() {
		var menu = $(this).parent();
		$("ul", menu).slideDown("fast", function() {
			menu.removeClass("collapsed").addClass("expanded");
		});
	});

	/* responsive text */
	function updateResponsiveText() {
		if(screen.width <= 480 || navigator.userAgent.match(/Android/i) || navigator.userAgent.match(/webOS/i) || navigator.userAgent.match(/iPhone/i) || navigator.userAgent.match(/iPod/i)) {
			$(".menuWrapper > .phoneFirstMenu").show();
			var carousel = $(".content > .carousel");
			$("img", carousel).attr("src", $(carousel).data("phone"));
			carousel = $(".content .main > .carousel");
			$("img", carousel).attr("src", $(carousel).data("phone"));
			/*
			//disable chatter links
			$(".actorentitylink").click(function(event){
   			event.preventDefault();
			});
			$(".feeditemsecondentity").click(function(event){
   			return false;
			});
			$(".feeditemfirstentity").click(function(event){
	   		return false;
			});
			$(".contentFileTitle").click(function(event){
	   		return false;
			});
			$(".feeditemtext > a").click(function(event){
	   		return false;
			});
			$(".trackedChangeRollover > a").click(function(event){
	   		return false;
			});
			$(".feedcommenttext > a").click(function(event){
	   		return false;
			});
			$(".chatter-photo").closest("a").click(function(event){
	   		return false;
			});
			$(".more-file-actions").hide();
			//disable upload file from salesforce functionality
			$('.chatterPublisherFileActionContainerLeft').remove();
			*/
			$(".cardContent").css('overflow-x','hidden');
			$(".cardContent").css('overflow-y','overlay');
			$(".cardLastPhone").after($(".cardPhone"));
			$('.mapCalendarBoard iframe').width('290px'); 
			$('.mapCalendarBoard iframe').height('400px'); 
		}/*
		else if(screen.width <= 786) {
			$(".menuWrapper .menu").show();
			$(".menuWrapper .phoneFirstMenu").hide();
			var carousel = $(".content > .carousel");
			$("img", carousel).attr("src", $(carousel).data("desktop"));
			carousel = $(".content .main > .carousel");
			$("img", carousel).attr("src", $(carousel).data("desktop"));
			// performance card text
			$('.card .dateTabs a:eq(1) span span').text("MTD");
			$('.card .dateTabs a:eq(2) span span').text("YTD");
			// news contentCard
			$(".contentCard .shortContent .text p").text("Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Morbi commodo, ipsum sed pharetra gravida, orci magna rhoncus...");
		}*/
		else {
			$(".menuWrapper .menu").show();
			$(".menuWrapper .phoneFirstMenu").hide();
			var carousel = $(".content > .carousel");
			$("img", carousel).attr("src", $(carousel).data("desktop"));
			// performance card text
			$('.card .dateTabs').eq(1).text("Month to Date");
			$('.card .dateTabs').eq(2).text("Year to Date");
			$('.mapCalendarBoard iframe').width('100%'); 
		}
		if(navigator.userAgent.match(/iPad/i)){
			var $viewport = $('meta[name="viewport"]');
			$viewport.attr('content','width=1236,user-scalable=yes');
		}
	}
	$(window).resize(function () {
		updateResponsiveText();
	});
	updateResponsiveText();
	/* end of responsive text */
});