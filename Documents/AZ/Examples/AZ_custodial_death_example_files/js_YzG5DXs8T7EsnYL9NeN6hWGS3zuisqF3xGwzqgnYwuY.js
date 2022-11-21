/**
 * @file Contains the jQuery "webks Responsive Table" Plugin.
 * 
 * @version 1.0.0
 * @since 2012-08-20
 * @see Project home:
 * @category responsive webdesign, jquery
 * @author webks:websolutions kept simple - Julian Pustkuchen & Thomas Frobieter
 *         GbR | http://www.webks.de
 * @copyright webks:websolutions kept simple - Julian Pustkuchen & Thomas
 *            Frobieter GbR | http://www.webks.de
 */
(function($) {
  /*
   * Usage Examples:
   *  -- Simple: -- Make all tables responsible using the default settings.
   * $('table').responsiveTable();
   *  -- Custom configuration example 1 (Disable manual switch): --
   * $('table').responsiveTable({ showSwitch: false });
   *  -- Custom configuration example 2 (Use different selectors): --
   * $('table').responsiveTable({ headerSelector: 'tr th', bodyRowSelector:
   * 'tr', });
   *  -- Custom configuration example 3 (Use different screensize in dynamic
   * mode): -- $('table').responsiveTable({ displayResponsiveCallback:
   * function() { return $(document).width() < 500; // Show responsive if screen
   * width < 500px }, });
   *  -- Custom configuration example 4 (Make ALL tables responsive - regardless
   * of screensize): -- $('table').responsiveTable({ dynamic: false });
   */

  /**
   * jQuery "webks Responsive Table" plugin transforms less mobile compliant
   * default HTML Tables into a flexible responsive format. Furthermore it
   * provides some nice configuration options to optimize it for your special
   * needs.
   * 
   * Technically the selected tables are being transformed into a list of
   * (definition) lists. The table header columns are used as title for each
   * value.
   * 
   * Functionality: - Select tables easily by jQuery selector. - Provide custom
   * rules (by callback function) for transformation into tables mobile version. -
   * Hard or dynamic switching for selected tables. - Use custom header and
   * content rows selectors. - Provides an optional, customizable link to
   * default table layout. - (Optionally) preserves most of the table elements
   * class attributes. - Decide if the original table is kept in DOM and set
   * invisible or completely removed. - Update display type (Table / Responsive &
   * re-calculate dynamic switch) by easily calling
   * .responsiveTableUpdate()-function.
   * 
   * Functionality may be applied to all DOM table elements. See examples above.
   * Please ensure that the settings match your requirements and your table
   * structure is compliant.
   */
  $.fn.responsiveTable = function(options) {
    return $(this).each(function(){
      $(this).responsiveTableInit(options);
    });
  };

  /**
   * Initializes the responsive tables. Expects to be executed on DOM table
   * elements only. These are being transformed into responsive tables like
   * configured.
   * 
   * @param options
   *            Optional JSON list of settings.
   */
  $.fn.responsiveTableInit = function(options) {
    var settings = $.extend({
      /**
       * Keep table components classes as far as possible for the responsive
       * output.
       */
      preserveClasses : true,
      /**
       * true: Toggle table style if settings.dynamicSwitch() returns true.
       * false: Only convert to mobile (one way)
       */
      dynamic : true,
      /**
       * (Only used if dynamic!) If this function returns true, the responsive
       * version is shown, else displays the default table. Might be used to set
       * a switch based on orientation, screen size, ... for dynamic switching!
       * 
       * @return boolean
       */
      displayResponsiveCallback : function() {
        return $(document).width() < 960;
      },
      /**
       * (Only used if dynamic!) Display a link to switch back from responsive
       * version to original table version.
       */
      showSwitch : true,
      /**
       * (Only used if showSwitch: true!) The title of the switch link.
       */
      switchTitle : 'Switch to default table view.',
      
      // Selectors
      /**
       * The header columns selector.
       * Default: 'thead td, thead th';
       * other examples: 'tr th', ...
       */
      headerSelector : 'thead td, thead th',
      /**
       * The body rows selector.
       * Default: 'tbody tr';
       * Other examples: 'tr', ...
       */
      bodyRowSelector : 'tbody tr',
      
      // Elements
      /**
       * The responsive rows container
       * element. 
       * Default: '<dl></dl>';
       * Other examples: '<ul></ul>'.
       */
      responsiveRowElement : '<dl></dl>',
      /**
       * The responsive column title
       * container element.
       * Default: '<dt></dt>'; 
       * Other examples: '<li></li>'.
       */
      responsiveColumnTitleElement : '<dt></dt>',
      /**
       * The responsive column value container element. 
       * Default: '<dd></dd>'; 
       * Other examples: '<li></li>'.
       */
      responsiveColumnValueElement : '<dd></dd>'
    }, options);

    return this.each(function() {
      // $this = The table (each).
      var $this = $(this);

      // Ensure that the element this is being executed on a table!
      $this._responsiveTableCheckElement(false);

      if ($this.data('webks-responsive-table-processed')) {
        // Only update if already processed.
        $this.responsiveTableUpdate();
        return true;
      }

      // General
      var result = $('<div></div>');
      result.addClass('webks-responsive-table');
      if (settings.preserveClasses) {
        result.addClass($this.attr('class'));
      }

      // Head
      // Iterate head - extract titles
      var titles = new Array();
      $this.find(settings.headerSelector).each(function(i, e) {
        var title = $(this).html();
        titles[i] = title;
      });

      // Body
      // Iterate body
      $this.find(settings.bodyRowSelector).each(function(i, e) {
        // Row
        var row = $(settings.responsiveRowElement);
        row.addClass('row row-' + i);
        if (settings.preserveClasses) {
          row.addClass($(this).attr('class'));
        }
        // Column
        $(this).children('td').each(function(ii, ee) {
          var dt = $(settings.responsiveColumnTitleElement);
          if (settings.preserveClasses) {
            dt.addClass($(this).attr('class'));
          }
          dt.addClass('title col-' + ii);
          dt.html(titles[ii]);
          var dd = $(settings.responsiveColumnValueElement);
          if (settings.preserveClasses) {
            dd.addClass($(this).attr('class'));
          }
          dd.addClass('value col-' + ii);
          dd.html($(this).html());
          // Set empty class if value is empty.
          if ($.trim($(this).html()) == '') {
            dd.addClass('empty');
            dt.addClass('empty');
          }
          row.append(dt).append(dd);
        });
        result.append(row);
      });

      // Display responsive version after table.
      $this.after(result);

      // Further + what shell we do with the processed table now?
      if (settings.dynamic) {
        if (settings.showSwitch) {
          var switchBtn = $('<a>');
          switchBtn.html(settings.switchTitle);
          switchBtn.addClass('switchBtn btn');
          switchBtn.attr('href', '#');

          $('div.webks-responsive-table a.switchBtn').live('click',
              function(e) {
                $this.responsiveTableShowTable();
                e.preventDefault();
                return false;
              });
          result.prepend(switchBtn);
        }

        // Connect result to table
        $this.data('webks-responsive-table', result);
        $this.data('webks-responsive-table-processed', true);

        // Connect table to result.
        result.data('table', $this);
        result.data('settings', settings);
        $this.data('webks-responsive-table-processed', true);

        // Hide table. We might need it again!
        $this.hide();

        // Run check to display right display version (table or responsive)
        $this.responsiveTableUpdate();
      } else {
        // Remove table entirely.
        $this.remove();
      }
    });
  };
  /**
   * Re-Check the .displayResponsiveCallback() and display table according to
   * its result. Only available if settings.dynamic is true.
   * 
   * May be called on Window resize, Orientation Change, ... Must be executed on
   * already processed DOM table elements.
   */
  $.fn.responsiveTableUpdate = function() {
    return this.each(function() {
      // $this = The table (each).
      var $this = $(this);

      // Ensure that the element this is being executed on must be a table!
      $this._responsiveTableCheckElement(true);

      var responsiveTable = $this.data('webks-responsive-table');
      if (responsiveTable != undefined) {
        var settings = responsiveTable.data('settings');
        if (settings != undefined) {
          // Check preconditions!
          if (settings.dynamic) {
            // Is dynamic!
            if (!settings.displayResponsiveCallback()) {
              // NOT matching defined responsive conditions!
              // Show original table and skip!
              $this.responsiveTableShowTable();
            } else {
              $this.responsiveTableShowResponsive();
            }
          }
        }
      }
    });
  };
  /**
   * Displays the default table style and hides the responsive layout.
   * 
   * Only available if settings.dynamic is true. Does nothing if the current
   * display is already as wished.
   */
  $.fn.responsiveTableShowTable = function() {
    return this.each(function() {
      // $this = The table (each).
      var $this = $(this);
      // Ensure that the element this is being executed on must be a table!
      $this._responsiveTableCheckElement(true);

      var responsiveTable = $this.data('webks-responsive-table');
      if (responsiveTable.length > 0) {
        $this.show();
        responsiveTable.hide();
      }
    });
  };

  /**
   * Displays the responsive style and hides the default table layout.
   * 
   * Only available if settings.dynamic is true. Does nothing if the current
   * display is already as wished.
   */
  $.fn.responsiveTableShowResponsive = function() {
    return this.each(function() {
      // $this = The table (each).
      var $this = $(this);
      // Ensure that the element this is being executed on must be a table!
      $this._responsiveTableCheckElement();

      var responsiveTable = $this.data('webks-responsive-table');
      if (responsiveTable.length > 0) {
        $this.hide();
        responsiveTable.show();
      }
    });
  };

  /**
   * Checks the general preconditions for elements that this Plugin is being
   * executed on.
   * 
   * @throws Exception
   *             if the given DOM element is not a table.
   * @throws Exception
   *             if a helper method is directly called on a not yet initialized
   *             table.
   */
  $.fn._responsiveTableCheckElement = function(checkProcessed) {
    if (checkProcessed === undefined) {
      checkProcessed = true;
    }
    var $this = $(this);
    if (!$this.is('table')) {
      throw 'The selected DOM element may only be a table!';
    }    
    if (checkProcessed
        && ($this.data('webks-responsive-table-processed') === undefined || !$this
            .data('webks-responsive-table-processed'))) {
      throw 'The selected DOM element has to be initialized by webks-responsive-table first.';
    }
    return $this;
  };
})(jQuery);
;
(function($) {
  /**
   * Initialization
   */
  Drupal.behaviors.jquery_wrt = {
    /**
     * Run Drupal module JS initialization.
     * 
     * @param context
     * @param settings
     */
    attach : function(context, settings) {
      // Global context!
      var filter = "table";
      if(jQuery.trim(settings.jquery_wrt.jquery_wrt_subselector) != ''){
        // Subselector
        filter = filter + settings.jquery_wrt.jquery_wrt_subselector;
      }
      var elements = $(context).find(filter);
      
      var responsiveTable = elements.responsiveTable({
        // Get default options from drupal to make them easier accessible.
        /**
         * Keep table components classes as far as possible for the responsive
         * output.
         */
        preserveClasses : settings.jquery_wrt.jquery_wrt_preserve_classes,
        /**
         * true: Toggle table style if settings.dynamicSwitch() returns true.
         * false: Only convert to mobile (one way)
         */
        dynamic : settings.jquery_wrt.jquery_wrt_dynamic,
        /**
         * (Only used if dynamic!) If this function returns true, the responsive
         * version is shown, else displays the default table. Might be used to set
         * a switch based on orientation, screen size, ... for dynamic switching!
         * 
         * @return boolean
         */
        displayResponsiveCallback : function() {
          return $(document).width() < settings.jquery_wrt.jquery_wrt_breakpoint;
        },
        /**
         * (Only used if dynamic!) Display a link to switch back from responsive version to original table version.
         */
        showSwitch : settings.jquery_wrt.jquery_wrt_showswitch,
        /**
         * (Only used if showSwitch: true!) The title of the switch link.
         */
        switchTitle : Drupal.t('Switch to default table view'),
        
        // Selectors
        /**
         * The header columns selector.
         * Default: 'thead td, thead th';
         * other examples: 'tr th', ...
         */
        headerSelector : settings.jquery_wrt.jquery_wrt_header_selector,
        /**
         * The body rows selector.
         * Default: 'tbody tr';
         * Other examples: 'tr', ...
         */
        bodyRowSelector : settings.jquery_wrt.jquery_wrt_row_selector,
        
        // Elements
        /**
         * The responsive rows container
         * element. 
         * Default: '<dl></dl>';
         * Other examples: '<ul></ul>'.
         */
        responsiveRowElement : settings.jquery_wrt.jquery_wrt_responsive_row_element,
        /**
         * The responsive column title
         * container element.
         * Default: '<dt></dt>'; 
         * Other examples: '<li></li>'.
         */
        responsiveColumnTitleElement : settings.jquery_wrt.jquery_wrt_row_responsive_column_title_element,
        /**
         * The responsive column value container element. 
         * Default: '<dd></dd>'; 
         * Other examples: '<li></li>'.
         */
        responsiveColumnValueElement : settings.jquery_wrt.jquery_wrt_row_responsive_column_value_element
      });
      
      // Update on Window Resize! (May be buggy in some browsers, sorry.)
      if(settings.jquery_wrt.jquery_wrt_update_on_resize){
        $(window).resize(function() {
          responsiveTable.responsiveTableUpdate();
        });
      }
      
      // Attach object globally to make access easy for custom usage.
      Drupal.behaviors.jquery_wrt.responsiveTable = responsiveTable;
    }
  };
})(jQuery);;
/**
 * @file
 * Some basic behaviors and utility functions for Views.
 */
(function ($) {

  Drupal.Views = {};

  /**
   * JQuery UI tabs, Views integration component.
   */
  Drupal.behaviors.viewsTabs = {
    attach: function (context) {
      if ($.viewsUi && $.viewsUi.tabs) {
        $('#views-tabset').once('views-processed').viewsTabs({
          selectedClass: 'active'
        });
      }

      $('a.views-remove-link').once('views-processed').click(function(event) {
        var id = $(this).attr('id').replace('views-remove-link-', '');
        $('#views-row-' + id).hide();
        $('#views-removed-' + id).attr('checked', true);
        event.preventDefault();
      });
      /**
    * Here is to handle display deletion
    * (checking in the hidden checkbox and hiding out the row).
    */
      $('a.display-remove-link')
        .addClass('display-processed')
        .click(function() {
          var id = $(this).attr('id').replace('display-remove-link-', '');
          $('#display-row-' + id).hide();
          $('#display-removed-' + id).attr('checked', true);
          return false;
        });
    }
  };

  /**
 * Helper function to parse a querystring.
 */
  Drupal.Views.parseQueryString = function (query) {
    var args = {};
    var pos = query.indexOf('?');
    if (pos != -1) {
      query = query.substring(pos + 1);
    }
    var pairs = query.split('&');
    for (var i in pairs) {
      if (typeof(pairs[i]) == 'string') {
        var pair = pairs[i].split('=');
        // Ignore the 'q' path argument, if present.
        if (pair[0] != 'q' && pair[1]) {
          args[decodeURIComponent(pair[0].replace(/\+/g, ' '))] = decodeURIComponent(pair[1].replace(/\+/g, ' '));
        }
      }
    }
    return args;
  };

  /**
 * Helper function to return a view's arguments based on a path.
 */
  Drupal.Views.parseViewArgs = function (href, viewPath) {

    // Provide language prefix.
    if (Drupal.settings.pathPrefix) {
      var viewPath = Drupal.settings.pathPrefix + viewPath;
    }
    var returnObj = {};
    var path = Drupal.Views.getPath(href);
    // Ensure we have a correct path.
    if (viewPath && path.substring(0, viewPath.length + 1) == viewPath + '/') {
      var args = decodeURIComponent(path.substring(viewPath.length + 1, path.length));
      returnObj.view_args = args;
      returnObj.view_path = path;
    }
    return returnObj;
  };

  /**
 * Strip off the protocol plus domain from an href.
 */
  Drupal.Views.pathPortion = function (href) {
    // Remove e.g. http://example.com if present.
    var protocol = window.location.protocol;
    if (href.substring(0, protocol.length) == protocol) {
      // 2 is the length of the '//' that normally follows the protocol.
      href = href.substring(href.indexOf('/', protocol.length + 2));
    }
    return href;
  };

  /**
 * Return the Drupal path portion of an href.
 */
  Drupal.Views.getPath = function (href) {
    href = Drupal.Views.pathPortion(href);
    href = href.substring(Drupal.settings.basePath.length, href.length);
    // 3 is the length of the '?q=' added to the url without clean urls.
    if (href.substring(0, 3) == '?q=') {
      href = href.substring(3, href.length);
    }
    var chars = ['#', '?', '&'];
    for (var i in chars) {
      if (href.indexOf(chars[i]) > -1) {
        href = href.substr(0, href.indexOf(chars[i]));
      }
    }
    return href;
  };

})(jQuery);
;
(function ($) {

/**
 * A progressbar object. Initialized with the given id. Must be inserted into
 * the DOM afterwards through progressBar.element.
 *
 * method is the function which will perform the HTTP request to get the
 * progress bar state. Either "GET" or "POST".
 *
 * e.g. pb = new progressBar('myProgressBar');
 *      some_element.appendChild(pb.element);
 */
Drupal.progressBar = function (id, updateCallback, method, errorCallback) {
  var pb = this;
  this.id = id;
  this.method = method || 'GET';
  this.updateCallback = updateCallback;
  this.errorCallback = errorCallback;

  // The WAI-ARIA setting aria-live="polite" will announce changes after users
  // have completed their current activity and not interrupt the screen reader.
  this.element = $('<div class="progress" aria-live="polite"></div>').attr('id', id);
  this.element.html('<div class="bar"><div class="filled"></div></div>' +
                    '<div class="percentage"></div>' +
                    '<div class="message">&nbsp;</div>');
};

/**
 * Set the percentage and status message for the progressbar.
 */
Drupal.progressBar.prototype.setProgress = function (percentage, message) {
  if (percentage >= 0 && percentage <= 100) {
    $('div.filled', this.element).css('width', percentage + '%');
    $('div.percentage', this.element).html(percentage + '%');
  }
  $('div.message', this.element).html(message);
  if (this.updateCallback) {
    this.updateCallback(percentage, message, this);
  }
};

/**
 * Start monitoring progress via Ajax.
 */
Drupal.progressBar.prototype.startMonitoring = function (uri, delay) {
  this.delay = delay;
  this.uri = uri;
  this.sendPing();
};

/**
 * Stop monitoring progress via Ajax.
 */
Drupal.progressBar.prototype.stopMonitoring = function () {
  clearTimeout(this.timer);
  // This allows monitoring to be stopped from within the callback.
  this.uri = null;
};

/**
 * Request progress data from server.
 */
Drupal.progressBar.prototype.sendPing = function () {
  if (this.timer) {
    clearTimeout(this.timer);
  }
  if (this.uri) {
    var pb = this;
    // When doing a post request, you need non-null data. Otherwise a
    // HTTP 411 or HTTP 406 (with Apache mod_security) error may result.
    $.ajax({
      type: this.method,
      url: this.uri,
      data: '',
      dataType: 'json',
      success: function (progress) {
        // Display errors.
        if (progress.status == 0) {
          pb.displayError(progress.data);
          return;
        }
        // Update display.
        pb.setProgress(progress.percentage, progress.message);
        // Schedule next timer.
        pb.timer = setTimeout(function () { pb.sendPing(); }, pb.delay);
      },
      error: function (xmlhttp) {
        pb.displayError(Drupal.ajaxError(xmlhttp, pb.uri));
      }
    });
  }
};

/**
 * Display errors on the page.
 */
Drupal.progressBar.prototype.displayError = function (string) {
  var error = $('<div class="messages error"></div>').html(string);
  $(this.element).before(error).hide();

  if (this.errorCallback) {
    this.errorCallback(this);
  }
};

})(jQuery);
;
/**
 * @file
 * Handles AJAX fetching of views, including filter submission and response.
 */
(function ($) {

  /**
   * Attaches the AJAX behavior to exposed filter forms and key views links.
   */
  Drupal.behaviors.ViewsAjaxView = {};
  Drupal.behaviors.ViewsAjaxView.attach = function() {
    if (Drupal.settings && Drupal.settings.views && Drupal.settings.views.ajaxViews) {
      $.each(Drupal.settings.views.ajaxViews, function(i, settings) {
        Drupal.views.instances[i] = new Drupal.views.ajaxView(settings);
      });
    }
  };

  Drupal.views = {};
  Drupal.views.instances = {};

  /**
   * Javascript object for a certain view.
   */
  Drupal.views.ajaxView = function(settings) {
    var selector = '.view-dom-id-' + settings.view_dom_id;
    this.$view = $(selector);

    // Retrieve the path to use for views' ajax.
    var ajax_path = Drupal.settings.views.ajax_path;

    // If there are multiple views this might've ended up showing up multiple
    // times.
    if (ajax_path.constructor.toString().indexOf("Array") != -1) {
      ajax_path = ajax_path[0];
    }

    // Check if there are any GET parameters to send to views.
    var queryString = window.location.search || '';
    if (queryString !== '') {
      // Remove the question mark and Drupal path component if any.
      var queryString = queryString.slice(1).replace(/q=[^&]+&?|&?render=[^&]+/, '');
      if (queryString !== '') {
        // If there is a '?' in ajax_path, clean url are on and & should be
        // used to add parameters.
        queryString = ((/\?/.test(ajax_path)) ? '&' : '?') + queryString;
      }
    }

    this.element_settings = {
      url: ajax_path + queryString,
      submit: settings,
      setClick: true,
      event: 'click',
      selector: selector,
      progress: {
        type: 'throbber'
      }
    };

    this.settings = settings;

    // Add the ajax to exposed forms.
    this.$exposed_form = $('#views-exposed-form-' + settings.view_name.replace(/_/g, '-') + '-' + settings.view_display_id.replace(/_/g, '-'));
    this.$exposed_form.once(jQuery.proxy(this.attachExposedFormAjax, this));

    // Store Drupal.ajax objects here for all pager links.
    this.links = [];

    // Add the ajax to pagers.
    this.$view
    // Don't attach to nested views. Doing so would attach multiple behaviors
    // to a given element.
      .filter(jQuery.proxy(this.filterNestedViews, this))
      .once(jQuery.proxy(this.attachPagerAjax, this));

    // Add a trigger to update this view specifically. In order to trigger a
    // refresh use the following code.
    //
    // @code
    // jQuery('.view-name').trigger('RefreshView');
    // @endcode
    // Add a trigger to update this view specifically.
    var self_settings = this.element_settings;
    self_settings.event = 'RefreshView';
    this.refreshViewAjax = new Drupal.ajax(this.selector, this.$view, self_settings);
  };

  Drupal.views.ajaxView.prototype.attachExposedFormAjax = function() {
    var button = $('input[type=submit], button[type=submit], input[type=image]', this.$exposed_form);
    button = button[0];

    // Call the autocomplete submit before doing AJAX.
    $(button).click(function () {
      if (Drupal.autocompleteSubmit) {
        Drupal.autocompleteSubmit();
      }
    });

    this.exposedFormAjax = new Drupal.ajax($(button).attr('id'), button, this.element_settings);
  };

  Drupal.views.ajaxView.prototype.filterNestedViews = function() {
    // If there is at least one parent with a view class, this view
    // is nested (e.g., an attachment). Bail.
    return !this.$view.parents('.view').length;
  };

  /**
   * Attach the ajax behavior to each link.
   */
  Drupal.views.ajaxView.prototype.attachPagerAjax = function() {
    this.$view.find('ul.pager > li > a, th.views-field a, .attachment .views-summary a')
      .each(jQuery.proxy(this.attachPagerLinkAjax, this));
  };

  /**
   * Attach the ajax behavior to a singe link.
   */
  Drupal.views.ajaxView.prototype.attachPagerLinkAjax = function(id, link) {
    var $link = $(link);
    var viewData = {};
    var href = $link.attr('href');
    // Construct an object using the settings defaults and then overriding
    // with data specific to the link.
    $.extend(
    viewData,
    this.settings,
    Drupal.Views.parseQueryString(href),
    // Extract argument data from the URL.
    Drupal.Views.parseViewArgs(href, this.settings.view_base_path)
    );

    // For anchor tags, these will go to the target of the anchor rather
    // than the usual location.
    $.extend(viewData, Drupal.Views.parseViewArgs(href, this.settings.view_base_path));

    this.element_settings.submit = viewData;
    this.pagerAjax = new Drupal.ajax(false, $link, this.element_settings);
    this.links.push(this.pagerAjax);
  };

  Drupal.ajax.prototype.commands.viewsScrollTop = function (ajax, response, status) {
    // Scroll to the top of the view. This will allow users
    // to browse newly loaded content after e.g. clicking a pager
    // link.
    var offset = $(response.selector).offset();
    // We can't guarantee that the scrollable object should be
    // the body, as the view could be embedded in something
    // more complex such as a modal popup. Recurse up the DOM
    // and scroll the first element that has a non-zero top.
    var scrollTarget = response.selector;
    while ($(scrollTarget).scrollTop() == 0 && $(scrollTarget).parent()) {
      scrollTarget = $(scrollTarget).parent();
    }
    // Only scroll upward.
    if (offset.top - 10 < $(scrollTarget).scrollTop()) {
      $(scrollTarget).animate({scrollTop: (offset.top - 10)}, 500);
    }
  };

})(jQuery);
;
/**
 * @file
 * Configures newly created contextual links to work with quicktabs.
 */

(function ($) {
  Drupal.behaviors.quicktabsContextual = {
    attach: function (context, settings) {
      $('a.quicktabs-contextual', context).once('init-quicktabs-contextual-processed').click(function () {
        var rel = $(this).attr('rel');
        $('#' + rel).click();
        return false;
      });

      $('.block-mbp-defaults').find('ul.quicktabs-tabs').hide();
    }
  }
})(jQuery);
;
(function ($) {

Drupal.googleanalytics = {};

$(document).ready(function() {

  // Attach mousedown, keyup, touchstart events to document only and catch
  // clicks on all elements.
  $(document.body).bind("mousedown keyup touchstart", function(event) {

    // Catch the closest surrounding link of a clicked element.
    $(event.target).closest("a,area").each(function() {

      // Is the clicked URL internal?
      if (Drupal.googleanalytics.isInternal(this.href)) {
        // Skip 'click' tracking, if custom tracking events are bound.
        if ($(this).is('.colorbox') && (Drupal.settings.googleanalytics.trackColorbox)) {
          // Do nothing here. The custom event will handle all tracking.
          //console.info("Click on .colorbox item has been detected.");
        }
        // Is download tracking activated and the file extension configured for download tracking?
        else if (Drupal.settings.googleanalytics.trackDownload && Drupal.googleanalytics.isDownload(this.href)) {
          // Download link clicked.
          ga("send", {
            "hitType": "event",
            "eventCategory": "Downloads",
            "eventAction": Drupal.googleanalytics.getDownloadExtension(this.href).toUpperCase(),
            "eventLabel": Drupal.googleanalytics.getPageUrl(this.href),
            "transport": "beacon"
          });
        }
        else if (Drupal.googleanalytics.isInternalSpecial(this.href)) {
          // Keep the internal URL for Google Analytics website overlay intact.
          ga("send", {
            "hitType": "pageview",
            "page": Drupal.googleanalytics.getPageUrl(this.href),
            "transport": "beacon"
          });
        }
      }
      else {
        if (Drupal.settings.googleanalytics.trackMailto && $(this).is("a[href^='mailto:'],area[href^='mailto:']")) {
          // Mailto link clicked.
          ga("send", {
            "hitType": "event",
            "eventCategory": "Mails",
            "eventAction": "Click",
            "eventLabel": this.href.substring(7),
            "transport": "beacon"
          });
        }
        else if (Drupal.settings.googleanalytics.trackOutbound && this.href.match(/^\w+:\/\//i)) {
          if (Drupal.settings.googleanalytics.trackDomainMode !== 2 || (Drupal.settings.googleanalytics.trackDomainMode === 2 && !Drupal.googleanalytics.isCrossDomain(this.hostname, Drupal.settings.googleanalytics.trackCrossDomains))) {
            // External link clicked / No top-level cross domain clicked.
            ga("send", {
              "hitType": "event",
              "eventCategory": "Outbound links",
              "eventAction": "Click",
              "eventLabel": this.href,
              "transport": "beacon"
            });
          }
        }
      }
    });
  });

  // Track hash changes as unique pageviews, if this option has been enabled.
  if (Drupal.settings.googleanalytics.trackUrlFragments) {
    window.onhashchange = function() {
      ga("send", {
        "hitType": "pageview",
        "page": location.pathname + location.search + location.hash
      });
    };
  }

  // Colorbox: This event triggers when the transition has completed and the
  // newly loaded content has been revealed.
  if (Drupal.settings.googleanalytics.trackColorbox) {
    $(document).bind("cbox_complete", function () {
      var href = $.colorbox.element().attr("href");
      if (href) {
        ga("send", {
          "hitType": "pageview",
          "page": Drupal.googleanalytics.getPageUrl(href)
        });
      }
    });
  }

});

/**
 * Check whether the hostname is part of the cross domains or not.
 *
 * @param string hostname
 *   The hostname of the clicked URL.
 * @param array crossDomains
 *   All cross domain hostnames as JS array.
 *
 * @return boolean
 */
Drupal.googleanalytics.isCrossDomain = function (hostname, crossDomains) {
  /**
   * jQuery < 1.6.3 bug: $.inArray crushes IE6 and Chrome if second argument is
   * `null` or `undefined`, http://bugs.jquery.com/ticket/10076,
   * https://github.com/jquery/jquery/commit/a839af034db2bd934e4d4fa6758a3fed8de74174
   *
   * @todo: Remove/Refactor in D8
   */
  if (!crossDomains) {
    return false;
  }
  else {
    return $.inArray(hostname, crossDomains) > -1 ? true : false;
  }
};

/**
 * Check whether this is a download URL or not.
 *
 * @param string url
 *   The web url to check.
 *
 * @return boolean
 */
Drupal.googleanalytics.isDownload = function (url) {
  var isDownload = new RegExp("\\.(" + Drupal.settings.googleanalytics.trackDownloadExtensions + ")([\?#].*)?$", "i");
  return isDownload.test(url);
};

/**
 * Check whether this is an absolute internal URL or not.
 *
 * @param string url
 *   The web url to check.
 *
 * @return boolean
 */
Drupal.googleanalytics.isInternal = function (url) {
  var isInternal = new RegExp("^(https?):\/\/" + window.location.host, "i");
  return isInternal.test(url);
};

/**
 * Check whether this is a special URL or not.
 *
 * URL types:
 *  - gotwo.module /go/* links.
 *
 * @param string url
 *   The web url to check.
 *
 * @return boolean
 */
Drupal.googleanalytics.isInternalSpecial = function (url) {
  var isInternalSpecial = new RegExp("(\/go\/.*)$", "i");
  return isInternalSpecial.test(url);
};

/**
 * Extract the relative internal URL from an absolute internal URL.
 *
 * Examples:
 * - http://mydomain.com/node/1 -> /node/1
 * - http://example.com/foo/bar -> http://example.com/foo/bar
 *
 * @param string url
 *   The web url to check.
 *
 * @return string
 *   Internal website URL
 */
Drupal.googleanalytics.getPageUrl = function (url) {
  var extractInternalUrl = new RegExp("^(https?):\/\/" + window.location.host, "i");
  return url.replace(extractInternalUrl, '');
};

/**
 * Extract the download file extension from the URL.
 *
 * @param string url
 *   The web url to check.
 *
 * @return string
 *   The file extension of the passed url. e.g. "zip", "txt"
 */
Drupal.googleanalytics.getDownloadExtension = function (url) {
  var extractDownloadextension = new RegExp("\\.(" + Drupal.settings.googleanalytics.trackDownloadExtensions + ")([\?#].*)?$", "i");
  var extension = extractDownloadextension.exec(url);
  return (extension === null) ? '' : extension[1];
};

})(jQuery);
;
