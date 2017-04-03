var http = require('http');
var url = require('url');
var mime = require('mime-types');
var _ = require('underscore');
var snmp = require('net-snmp');
var fs = require('fs');
        
// Create server
var server = http.createServer(handleRequest);

// socket.io listen on server
var io = require('socket.io')(server);

// server listen on port 3000
server.listen(3000);
console.log("Server is listening on port 3000...");

// Global vars needed
const ROOT = "./";
var session = snmp.createSession("localhost", "public"); // start snmp
var everything = ["1.3.6.1.3.1.0"]; // OID has pid, pname, pram, pcmd
var sysInfo = ["1.3.16.1.3.1.1"]; // OID has load avg, cpu util, mem util
var info = {pids: [], pnames: [], prams: [],
            pcpus: [], pcmds: [], pdescs: []}; //  parse and sort information into this!
            

function handleRequest(req,res){

  //process the request
  console.log(req.method+" request for: "+req.url);

  //parse the url
  var urlObj = url.parse(req.url);
  var filename = ROOT+urlObj.pathname;

  //the callback sequence for static serving...
  fs.stat(filename,function(err, stats){
    if(err){   //try and open the file and handle the error, handle the error
      res.writeHead(404);
      res.end("404!!! File or folder not found")
    }else{
      if(stats.isDirectory()) filename="./index.html";

      fs.readFile(filename,"utf8",function(err, data){
        if(err){
          res.writeHead(500);
          res.end("500!!! Server error")
        }else{
          res.writeHead(200,{'content-type':mime.lookup(filename)||'text/html'});
          res.end(data);
        }
      });
    }
  });

};

io.on("connection", function(socket){
  console.log("Got a connection");

	// getValues periodically
  socket.on("getValues", function(data) {
		session.get (everything, function(error, varbinds){
			if (error) {
				console.error (error);
      } else {
				console.log("get snmp\n");
				
				for (var i = 0; i < varbinds.length; i++) {
					if (snmp.isVarbindError(varbinds[i])) {
						console.error (snmp.varbindError(varbinds[i]));
					} else {
						// clear old info
						// maybe find a way to merge/update.
						info = {pids: [], pnames: [], prams: [],
										pcpus: [], pcmds: [], pdescs: []};
										
						var temp = varbinds[i].value + "";
						temp = temp.split("\n");

						_.each(temp, function(line) {
							var sline = line.split(" ");
	
							if(sline[0] !== '') {
								info.pids.push(sline[0]);
								info.pnames.push(sline[1]);
							}
						});

						console.log (info);
						socket.emit("getValues", info);
					}
				}
      }
    });
  }); // END OF SOCKET: getValues
  
  socket.on("monitorProc", function(data) {
		
		const execFile = require("child_process").execFile;
		const child = execFile('bash',  ['cpumon.sh', data.pname, data.ulimit], (error, stdout, stderr) => {
			if (stderr) {
				console.log(stderr);
			}
			if (error){
				console.log(error);
			} else {
				socket.emit("monitorProc", stdout);
			}
		});
	});
	
	socket.on("akheeelyou", function(data) {
		var d =  data.split(" ");
		var name = d[1];
		console.log(name);

		const execFile = require("child_process").execFile;
		const child = execFile('bash',  ['killproc.sh', name], (error, stdout, stderr) => {
			if (stderr) {
				console.log(stderr);
			}
			if (error){
				console.log(error);
			} else {
				socket.emit("akheeelyou", stdout);
			}
		});
	});
});
