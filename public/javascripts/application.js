// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var tl;
var resizeTimerID = null;

function centerTimeline(date) {
    tl.getBand(0).setCenterVisibleDate(Timeline.DateTime.parseGregorianDateTime(date));
}


function onResize() {
    if (resizeTimerID == null) {
        resizeTimerID = window.setTimeout(function() {
            resizeTimerID = null;
            tl.layout();
        }, 500);
    }
}

