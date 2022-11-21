/* Google Analytics Code */
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-39773230-2']);
_gaq.push(['_trackPageview']);

(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();

//Site improve
(function() {
  var sz = document.createElement('script'); sz.type = 'text/javascript'; sz.async = true;
  sz.src = '//siteimproveanalytics.com/js/siteanalyze_6428.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(sz, s);
})();


jQuery(function($) {

  var sliverLink = document.createElement('link');
  sliverLink.href = 'https://static.az.gov/sliver/styles/sliver.css';
  sliverLink.type ='text/css';
  sliverLink.media = 'all';
  sliverLink.rel = 'stylesheet'
  document.body.appendChild(sliverLink);



  $(window).bind("load", function () {
    var sliverDiv = document.createElement('div');
    sliverDiv.setAttribute('role', 'navigation');
    sliverDiv.setAttribute('aria-label', 'State of Arizona Sliver');
    sliverDiv.className = "sliver-container";
    sliverDiv.innerHTML = '<ul class="sliver-ul">'

      /* Open Books */
      + '<li class="sliver-li-left"><a href="https://openbooks.az.gov" <a href="https://openbooks.az.gov/" title="Visit OpenBooks - Arizona\'s Official Transparency Website" target="_blank" rel="noopener">'
      + '<img class="sliver-img" src="https://static.az.gov/sliver/images/book-icon.png" title="Visit OpenBooks" alt="Book icon for the OpenBooks website"/>'
      + '<span class="hideTitle">Visit</span> <span>OpenBooks</span></a> </li>'

      /* Ombudsman-Citizens Aide */
      + '<li class="sliver-li-left"><a href="https://www.azoca.gov" title="The Ombudsman-Citizens Aide helps citizens to resolve ongoing issues with State Agencies" target="_blank" rel="noopener">'
      + '<img class="sliver-img" src="https://static.az.gov/sliver/images/ombudsman-icon.png" title="The Ombudsman-Citizens Aide helps citizens to resolve ongoing issues with State Agencies" alt="Silhouette of head and shoulders as an icon for the Ombudsman-Citizens Aide website"/>'
      + '<span class="hideTitle">Ombudsman-</span><span>Citizens Aide</span></a> </li>'

      /* Covid-19 */
      + '<li class="sliver-li-left"><a href="https://azdhs.gov/preparedness/epidemiology-disease-control/infectious-disease-epidemiology/index.php#novel-coronavirus-home" title="Get the facts on COVID-19" target="_blank" rel="noopener">'
      + '<span class="hideTitle">Get the facts on</span> <span>COVID-19</span></a> </li>'

      /* Search AZ*/
      + '<li class="sliver-li-right"><a href="https://az.gov/search/" target="_blank" rel="noopener">'
      + '<img class="sliver-img2" src="https://static.az.gov/sliver/images/icon-searchlink.png" title="Search AZ.Gov" alt="Magnifying glass symbolizing search az.gov" />'
      + '<span class="hide">Search</span> <span>AZ.Gov</span></a><a href="https://az.gov" target="_blank" rel="noopener">'
      + '<img id="sliver-logo" src="https://static.az.gov/sliver/images/logo-small.png" title="AZ.Gov" alt="Magnifying glass symbolizing search az.gov" /></a></li> '
      + '</ul>'
      + '</div>';

    var children = document.body.childNodes;
    if (!document.getElementById("skip-link")) {
      document.body.insertBefore(sliverDiv, document.body.firstChild);
    }else{
      document.body.insertBefore(sliverDiv, children[2]);
    }

  });
});
