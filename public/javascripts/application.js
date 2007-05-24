// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var tl;
function onLoad() {
  var eventSource = new Timeline.DefaultEventSource();
  var bandInfos = [
    Timeline.createBandInfo({
        eventSource:    eventSource,
        width:          "70%", 
        intervalUnit:   Timeline.DateTime.MONTH, 
        intervalPixels: 100
    }),
    Timeline.createBandInfo({
        showEventText:  false,
        trackHeight:    0.5,
        trackGap:       0.2,
        eventSource:    eventSource,
        width:          "30%", 
        intervalUnit:   Timeline.DateTime.YEAR, 
        intervalPixels: 200
    })
  ];
  bandInfos[1].syncWith = 0;
  bandInfos[1].highlight = true;
  
  tl = Timeline.create(document.getElementById("strands-timeline"), bandInfos);
  Timeline.loadXML("/strands/nodes.xml", function(xml, url) { eventSource.loadXML(xml, url); });
}

function onLoadShow() {
  var eventSource = new Timeline.DefaultEventSource();
  var bandInfos = [
    Timeline.createBandInfo({
        eventSource:    eventSource,
        width:          "70%", 
        intervalUnit:   Timeline.DateTime.MONTH, 
        intervalPixels: 100
    }),
    Timeline.createBandInfo({
        showEventText:  false,
        trackHeight:    0.5,
        trackGap:       0.2,
        eventSource:    eventSource,
        width:          "30%", 
        intervalUnit:   Timeline.DateTime.YEAR, 
        intervalPixels: 200
    })
  ];
  bandInfos[1].syncWith = 0;
  bandInfos[1].highlight = true;
  
  tl = Timeline.create(document.getElementById("strands-timeline"), bandInfos);
  Timeline.loadXML("/strands/show_nodes.xml", function(xml, url) { eventSource.loadXML(xml, url); });
}

var resizeTimerID = null;
function onResize() {
    if (resizeTimerID == null) {
        resizeTimerID = window.setTimeout(function() {
            resizeTimerID = null;
            tl.layout();
        }, 500);
    }
}
