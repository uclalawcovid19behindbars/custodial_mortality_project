(function ($) {

  $(document).bind('leaflet.map', function(e, map, lMap) {
    lMap.on('popupopen', function(e) {
      var popup = e.popup;
      var $popup = $(popup._contentNode);
      if ($popup.find('.view-location-unit-status').length) {
        var scroller = $popup.find('.view-location-unit-status')

        // Don't add the scroller for content that fits.
        if (scroller.width() <= 300 ) {
          return;
        }
        scroller.css({
          'max-width': '300px',
          'overflow': 'hidden'
        });
        scroller.marquee({
         delayBeforeStart: 0,
         duplicated: true
        });
      }
    });
  });

  Drupal.behaviors.corrections_custom = {
    attach: function (context, settings) {
      $('img').bind('contextmenu', function(e){ return false; });
    }
  };
})(jQuery);
;
/**
 * jQuery.marquee - scrolling text like old marquee element
 * @author Aamir Afridi - aamirafridi(at)gmail(dot)com / http://aamirafridi.com/jquery/jquery-marquee-plugin
 */
;(function(e){e.fn.marquee=function(t){return this.each(function(){var n=e.extend({},e.fn.marquee.defaults,t),r=e(this),i,s,o,u,a,f=3,l="animation-play-state",c=false,h=function(e,t,n){var r=["webkit","moz","MS","o",""];for(var i=0;i<r.length;i++){if(!r[i])t=t.toLowerCase();e.addEventListener(r[i]+t,n,false)}},p=function(e){var t=[];for(var n in e){if(e.hasOwnProperty(n)){t.push(n+":"+e[n])}}t.push();return"{"+t.join(",")+"}"},d=function(){r.timer=setTimeout(M,n.delayBeforeStart)},v={pause:function(){if(c&&n.allowCss3Support){i.css(l,"paused")}else{if(e.fn.pause){i.pause()}}r.data("runningStatus","paused");r.trigger("paused")},resume:function(){if(c&&n.allowCss3Support){i.css(l,"running")}else{if(e.fn.resume){i.resume()}}r.data("runningStatus","resumed");r.trigger("resumed")},toggle:function(){v[r.data("runningStatus")=="resumed"?"pause":"resume"]()},destroy:function(){clearTimeout(r.timer);r.find("*").andSelf().unbind();r.html(r.find(".js-marquee:first").html())}};if(typeof t==="string"){if(e.isFunction(v[t])){if(!i){i=r.find(".js-marquee-wrapper")}if(r.data("css3AnimationIsSupported")===true){c=true}v[t]()}return}var m={},g;e.each(n,function(e,t){g=r.attr("data-"+e);if(typeof g!=="undefined"){switch(g){case"true":g=true;break;case"false":g=false;break}n[e]=g}});n.duration=n.speed||n.duration;u=n.direction=="up"||n.direction=="down";n.gap=n.duplicated?parseInt(n.gap):0;r.wrapInner('<div class="js-marquee"></div>');var y=r.find(".js-marquee").css({"margin-right":n.gap,"float":"left"});if(n.duplicated){y.clone(true).appendTo(r)}r.wrapInner('<div style="width:100000px" class="js-marquee-wrapper"></div>');i=r.find(".js-marquee-wrapper");if(u){var b=r.height();i.removeAttr("style");r.height(b);r.find(".js-marquee").css({"float":"none","margin-bottom":n.gap,"margin-right":0});if(n.duplicated)r.find(".js-marquee:last").css({"margin-bottom":0});var w=r.find(".js-marquee:first").height()+n.gap;n.duration=(parseInt(w,10)+parseInt(b,10))/parseInt(b,10)*n.duration}else{a=r.find(".js-marquee:first").width()+n.gap;s=r.width();n.duration=(parseInt(a,10)+parseInt(s,10))/parseInt(s,10)*n.duration}if(n.duplicated){n.duration=n.duration/2}if(n.allowCss3Support){var E=document.body||document.createElement("div"),S="marqueeAnimation-"+Math.floor(Math.random()*1e7),x="Webkit Moz O ms Khtml".split(" "),T="animation",N="",C="";if(E.style.animation){C="@keyframes "+S+" ";c=true}if(c===false){for(var k=0;k<x.length;k++){if(E.style[x[k]+"AnimationName"]!==undefined){var L="-"+x[k].toLowerCase()+"-";T=L+T;l=L+l;C="@"+L+"keyframes "+S+" ";c=true;break}}}if(c){N=S+" "+n.duration/1e3+"s "+n.delayBeforeStart/1e3+"s infinite "+n.css3easing;r.data("css3AnimationIsSupported",true)}}var A=function(){i.css("margin-top",n.direction=="up"?b+"px":"-"+w+"px")},O=function(){i.css("margin-left",n.direction=="left"?s+"px":"-"+a+"px")};if(n.duplicated){if(u){i.css("margin-top",n.direction=="up"?b:"-"+(w*2-n.gap)+"px")}else{i.css("margin-left",n.direction=="left"?s+"px":"-"+(a*2-n.gap)+"px")}f=1}else{if(u){A()}else{O()}}var M=function(){if(n.duplicated){if(f===1){n._originalDuration=n.duration;if(u){n.duration=n.direction=="up"?n.duration+b/(w/n.duration):n.duration*2}else{n.duration=n.direction=="left"?n.duration+s/(a/n.duration):n.duration*2}if(N){N=S+" "+n.duration/1e3+"s "+n.delayBeforeStart/1e3+"s "+n.css3easing}f++}else if(f===2){n.duration=n._originalDuration;if(N){S=S+"0";C=e.trim(C)+"0 ";N=S+" "+n.duration/1e3+"s 0s infinite "+n.css3easing}f++}}if(u){if(n.duplicated){if(f>2){i.css("margin-top",n.direction=="up"?0:"-"+w+"px")}o={"margin-top":n.direction=="up"?"-"+w+"px":0}}else{A();o={"margin-top":n.direction=="up"?"-"+i.height()+"px":b+"px"}}}else{if(n.duplicated){if(f>2){i.css("margin-left",n.direction=="left"?0:"-"+a+"px")}o={"margin-left":n.direction=="left"?"-"+a+"px":0}}else{O();o={"margin-left":n.direction=="left"?"-"+a+"px":s+"px"}}}r.trigger("beforeStarting");if(c){i.css(T,N);var t=C+" { 100%  "+p(o)+"}",l=e("style");if(l.length!==0){l.filter(":last").append(t)}else{e("head").append("<style>"+t+"</style>")}h(i[0],"AnimationIteration",function(){r.trigger("finished")});h(i[0],"AnimationEnd",function(){M();r.trigger("finished")})}else{i.animate(o,n.duration,n.easing,function(){r.trigger("finished");if(n.pauseOnCycle){d()}else{M()}})}r.data("runningStatus","resumed")};r.bind("pause",v.pause);r.bind("resume",v.resume);if(n.pauseOnHover){r.bind("mouseenter mouseleave",v.toggle)}if(c&&n.allowCss3Support){M()}else{d()}})};e.fn.marquee.defaults={allowCss3Support:true,css3easing:"linear",easing:"linear",delayBeforeStart:1e3,direction:"left",duplicated:false,duration:5e3,gap:20,pauseOnCycle:false,pauseOnHover:false}})(jQuery);
;
(function ($) {

  Drupal.csustan_menu = {
    menu_created: false,
    responsive_width: 959,

    mobile_menu: function () {
      var mobile_menu = $('.mobile-menu-popout');
      var wrapper = $('.menu-block-wrapper', mobile_menu);

      if (Drupal.csustan_menu.menu_created) {
        if ($(window).width() >= Drupal.csustan_menu.responsive_width) {
          mobile_menu.hide();
        }

        return;
      }

      var mobile_menu_link = $('.mobile-menu-popout-link').click(function() {
        // Show the first level of links
        mobile_menu.toggle();
        $('ul.menu', mobile_menu).removeClass('menu-show');
        $('ul.menu', mobile_menu).eq(0).addClass('menu-show');
        wrapper.css('left', 0);
        return false;
      });

      // add back button
      mobile_menu.find(".expanded").each(function () {
        $(this).children("ul").prepend('<li class="title"><a href="#" class="back">Back</a> <a href="' + $(this).children("a").attr('href') + '"><span>' + $(this).children("a").text() + "</span></a></li>");
      });

/*
      // make page titles open the menu
      var current_page = $('ul.menu a.active', mobile_menu).eq(0);
      if (current_page[0]) {
        var parents = current_page.parents('ul.menu');
        if (parents.size() - 1 == 0) {
          // we need to add the section rather than the top level item, so find where the
          // title item is then use that to get the menu parents.
          parents = current_page.closest('li').children('ul.menu').children('li.title').parents('ul.menu');
        }
        $('h1#page-title').click(function() {
          if ($(window).width() > Drupal.csustan_menu.responsive_width) {
            $(this).css('cursor', '');
            mobile_menu.hide();
            return;
          }
          $(this).css('cursor', 'pointer');
          var depth = parents.size() - 1;
          mobile_menu.show();
          $('ul.menu', mobile_menu).removeClass('menu-show');
          parents.addClass('menu-show');
          wrapper.css('left', (-1 * depth * Drupal.csustan_menu.responsive_width) + 'px');
        }).css('cursor', 'pointer');
      }

      // hide the li for no-mobile items
      $.each($('a.no-mobile', mobile_menu), function() {
        $(this).closest('li').hide();
      });
*/

      $('ul.menu a', mobile_menu).click(function(event) {
        // make menus open sub items
        var position = wrapper.css("left");
        position = parseInt(position.replace("px", ""));
        var next_position = 0;

        var parent = $(this).closest('li');
        if (parent.hasClass('expanded') && $('ul.menu', parent).eq(0).size() > 0) {
          event.preventDefault();

          var current_width = $(window).width();
          next_position = position - current_width;
          $('ul.menu', parent).css('left', current_width);
          wrapper.stop().animate({
            left: next_position
          }, 250, function () {
            $('ul.menu', parent).eq(0).addClass('menu-show');
          });

          return false;
        }
        else if (parent.hasClass('title') && $(this).hasClass('back')) {
          // add back button functionality
          var current_width = $(window).width();
          parent.closest('ul.menu').removeClass('menu-show');
          wrapper.stop().animate({
            left: position + current_width
          }, 250, function () {
          });
          return false;
        }
      });

      Drupal.csustan_menu.menu_created = true;
    }
  }

  Drupal.behaviors.csustan_menu = {
    attach: function (context, settings) {
      if ($(window).width() <= Drupal.csustan_menu.responsive_width) {
        Drupal.csustan_menu.mobile_menu();
      }
    }
  }

  $(window).resize(function() {
    Drupal.csustan_menu.mobile_menu();
  });
})(jQuery);;
(function ($) {

Drupal.extlink = Drupal.extlink || {};

Drupal.extlink.attach = function (context, settings) {
  if (!settings.hasOwnProperty('extlink')) {
    return;
  }

  // Strip the host name down, removing ports, subdomains, or www.
  var pattern = /^(([^\/:]+?\.)*)([^\.:]{4,})((\.[a-z]{1,4})*)(:[0-9]{1,5})?$/;
  var host = window.location.host.replace(pattern, '$3$4');
  var subdomain = window.location.host.replace(pattern, '$1');

  // Determine what subdomains are considered internal.
  var subdomains;
  if (settings.extlink.extSubdomains) {
    subdomains = "([^/]*\\.)?";
  }
  else if (subdomain == 'www.' || subdomain == '') {
    subdomains = "(www\\.)?";
  }
  else {
    subdomains = subdomain.replace(".", "\\.");
  }

  // Build regular expressions that define an internal link.
  var internal_link = new RegExp("^https?://" + subdomains + host, "i");

  // Extra internal link matching.
  var extInclude = false;
  if (settings.extlink.extInclude) {
    extInclude = new RegExp(settings.extlink.extInclude.replace(/\\/, '\\'), "i");
  }

  // Extra external link matching.
  var extExclude = false;
  if (settings.extlink.extExclude) {
    extExclude = new RegExp(settings.extlink.extExclude.replace(/\\/, '\\'), "i");
  }

  // Extra external link CSS selector exclusion.
  var extCssExclude = false;
  if (settings.extlink.extCssExclude) {
    extCssExclude = settings.extlink.extCssExclude;
  }

  // Extra external link CSS selector explicit.
  var extCssExplicit = false;
  if (settings.extlink.extCssExplicit) {
    extCssExplicit = settings.extlink.extCssExplicit;
  }

  // Find all links which are NOT internal and begin with http as opposed
  // to ftp://, javascript:, etc. other kinds of links.
  // When operating on the 'this' variable, the host has been appended to
  // all links by the browser, even local ones.
  // In jQuery 1.1 and higher, we'd use a filter method here, but it is not
  // available in jQuery 1.0 (Drupal 5 default).
  var external_links = new Array();
  var mailto_links = new Array();
  $("a:not(." + settings.extlink.extClass + ", ." + settings.extlink.mailtoClass + "), area:not(." + settings.extlink.extClass + ", ." + settings.extlink.mailtoClass + ")", context).each(function(el) {
    try {
      var url = this.href.toLowerCase();
      if (url.indexOf('http') == 0
        && ((!url.match(internal_link) && !(extExclude && url.match(extExclude))) || (extInclude && url.match(extInclude)))
        && !(extCssExclude && $(this).parents(extCssExclude).length > 0)
        && !(extCssExplicit && $(this).parents(extCssExplicit).length < 1)) {
        external_links.push(this);
      }
      // Do not include area tags with begin with mailto: (this prohibits
      // icons from being added to image-maps).
      else if (this.tagName != 'AREA' 
        && url.indexOf('mailto:') == 0 
        && !(extCssExclude && $(this).parents(extCssExclude).length > 0)
        && !(extCssExplicit && $(this).parents(extCssExplicit).length < 1)) {
        mailto_links.push(this);
      }
    }
    // IE7 throws errors often when dealing with irregular links, such as:
    // <a href="node/10"></a> Empty tags.
    // <a href="http://user:pass@example.com">example</a> User:pass syntax.
    catch (error) {
      return false;
    }
  });

  if (settings.extlink.extClass) {
    Drupal.extlink.applyClassAndSpan(external_links, settings.extlink.extClass);
  }

  if (settings.extlink.mailtoClass) {
    Drupal.extlink.applyClassAndSpan(mailto_links, settings.extlink.mailtoClass);
  }

  if (settings.extlink.extTarget) {
    // Apply the target attribute to all links.
    $(external_links).attr('target', settings.extlink.extTarget);
  }

  Drupal.extlink = Drupal.extlink || {};

  // Set up default click function for the external links popup. This should be
  // overridden by modules wanting to alter the popup.
  Drupal.extlink.popupClickHandler = Drupal.extlink.popupClickHandler || function() {
    if (settings.extlink.extAlert) {
      return confirm(settings.extlink.extAlertText);
    }
   }

  $(external_links).click(function(e) {
    return Drupal.extlink.popupClickHandler(e);
  });
};

/**
 * Apply a class and a trailing <span> to all links not containing images.
 *
 * @param links
 *   An array of DOM elements representing the links.
 * @param class_name
 *   The class to apply to the links.
 */
Drupal.extlink.applyClassAndSpan = function (links, class_name) {
  var $links_to_process;
  if (Drupal.settings.extlink.extImgClass){
    $links_to_process = $(links);
  }
  else {
    var links_with_images = $(links).find('img').parents('a');
    $links_to_process = $(links).not(links_with_images);
  }
  $links_to_process.addClass(class_name);
  var i;
  var length = $links_to_process.length;
  for (i = 0; i < length; i++) {
    var $link = $($links_to_process[i]);
    if ($link.css('display') == 'inline' || $link.css('display') == 'inline-block') {
      if (class_name == Drupal.settings.extlink.mailtoClass) {
        $link.append('<span class="' + class_name + '"><span class="element-invisible"> ' + Drupal.settings.extlink.mailtoLabel + '</span></span>');
      }
      else {
        $link.append('<span class="' + class_name + '"><span class="element-invisible"> ' + Drupal.settings.extlink.extLabel + '</span></span>');
      }
    }
  }
};

Drupal.behaviors.extlink = Drupal.behaviors.extlink || {};
Drupal.behaviors.extlink.attach = function (context, settings) {
  // Backwards compatibility, for the benefit of modules overriding extlink
  // functionality by defining an "extlinkAttach" global function.
  if (typeof extlinkAttach === 'function') {
    extlinkAttach(context);
  }
  else {
    Drupal.extlink.attach(context, settings);
  }
};

})(jQuery);
;
