var socket = io();

$(document).ready(function(){
  // Attach click listeners to div#optionalcolumns
  // RAM, Path, Desc
  $(".optionalcolumns").click(columnToggle);
  
  socket.on("connect", function(){
    socket.emit("getValues", "");
	});
  
  socket.on("getValues", initValues);
  
  socket.on("monitorProc", function(data) {
    if (confirm(data + "\nDo you want to kill the process?")){
      socket.emit("akheeelyou", data);
    }
  });
  
  socket.on("akheeelyou", function(data){
    alert(data);
  });
});

function columnToggle() {
  console.log("Yes! "+ $(this).attr('id') + " was clicked");
}

function initValues(data) {
  console.log(data);
  for (var i = 0; i < data.pids.length; i++) {
     if(data.pnames[i] == "") {
       continue;
     }
     var idp = $("<p>");
     idp.append(data.pids[i]);
     var namep = $("<p>");
     namep.html(data.pnames[i]);
     idp.hover(onProc, outProc);
     namep.hover(onProc, outProc);
     idp.attr("class", data.pids[i]);
     namep.attr("class", data.pids[i]);
     $("#pid").append(idp);
     $(namep).dblclick(startMonitoring);
     $("#pname").append(namep);
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
    var procname = $(this).text();
    console.log("Double Click works: " + procname);
    var limit = prompt("Enter CPU% limit for " + procname + ": ");
    $("#monitor").append("Monitoring process " + procname + " with limit " + limit + "%");
    $("#monitor").append($("<br>"));
    socket.emit("monitorProc", {pname: procname, ulimit: limit});
}
