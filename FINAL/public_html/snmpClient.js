var socket = io();
var prevprocs = 0;
var flag = 0;
$(document).ready(function(){
  // Attach click listeners to div#optionalcolumns
  // RAM, Path, Desc
  $(".optionalcolumns").click(columnToggle);
  
});

socket.on("connect", function(){
	socket.emit("getValues", "");
});

var refreshInfo = setInterval(function(){
	socket.emit("getValues", "");
	}, 5000);

socket.on("getValues", initValues);

socket.on("monitorProc", function(data) {
	if (confirm(data + "\nDo you want to kill the process?")){
	  socket.emit("akheeelyou", data);
	} else {
		var temp = data.split(" ");
		removeElement(data.split(" ")[1]);
	}
});

socket.on("akheeelyou", function(data){
	alert(data);
	removeElement(data.split(" ")[0]);
});

function removeElement(ele) {
	var temp = "#"+ele;
	console.log(temp);
	$(temp).remove();
}
function columnToggle() {
  console.log("Yes! "+ $(this).attr('id') + " was clicked");
}

function initValues(data) {
  var send = {pids: []};
  console.log(data);
  if (prevprocs != data.pids.length){ 
	  prevprocs = data.pids.length;
	  flag = 1;
	  $("#pcmd").html("");
  } else {
	  flag = 0;
  }
  // system info
  $("#desc").html(data.desc);
  $("#ramu").html(data.usedram + " MiB");
  $("#ramf").html(data.freeram + " MiB");
  $("#ramt").html(data.totalram + " MiB");
  // procs
  $("#pid").html("");
  $("#pname").html("");
  $("#pram").html("");
  for (var i = 0; i < data.pids.length; i++) {
	 if(data.pnames[i] == "") {
	   continue;
	 }
	 var idp = $("<p>");
	 idp.append(data.pids[i]);
	 var namep = $("<p>");
	 namep.html(data.pnames[i]);
	 var ramp = $("<p>");
	 ramp.append(data.prams[i] + " MiB");
	 idp.hover(onProc, outProc);
	 namep.hover(onProc, outProc);
	 ramp.hover(onProc, outProc);
	 idp.attr("class", data.pids[i]);
	 namep.attr("class", data.pids[i]);
	 ramp.attr("class", data.pids[i]);
	 $("#pid").append(idp);
	 $(idp).dblclick(startMonitoring);
	 $("#pname").append(namep);
	 $("#pram").append(ramp);
	 if (flag == 1) {
		var locp = $("<p>");
		locp.append(data.pcmds[i]);
		locp.hover(onProc, outProc);
		locp.attr("class", data.pids[i]);
		$("#pcmd").append(locp);
	}
  }
}

function onProc() {
    var tagclass = $(this).attr("class");
    var temp = "." + tagclass;
    $(temp).css('background-color', 'red');
}

function outProc() {
    var tagclass = $(this).attr("class");
    var temp = "." + tagclass;
    $(temp).css('background-color', 'lightgrey');
}

function startMonitoring() {
    var procid = $(this).text();
    var limit = prompt("Enter CPU% limit for " + procid + ": ");
    var pmon = $("<p>");
    pmon.attr("id", procid);
    pmon.html("Process " + procid + " with CPU limit " + limit + "%");
    $("#monitorInfo").append(pmon);
    //$("#monitorInfo").append($("<br>"));
    socket.emit("monitorProc", {pid: procid, ulimit: limit});
}
