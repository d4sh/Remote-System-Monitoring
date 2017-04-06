# Remote System Monitoring 

File Setup:


public_html folder on Web Server


extension.pl in /usr/local/share/snmp (ROOT access needed)


Usage:


add snmp session with your agent using credentials in snmpServer.js -

  var sessionName = snmp.createSession("agent ip", "community"); 
  
  . etc
  
  .
  

Make sure your SNMP Agent is running:

  sudo service snmpd start
  
  
To check if your SNMP Agent is running:

  ps -ef | grep snmpd
  
  
Start Node.js Server (listerning on port 3000):

  sudo node snmpServer.js
  
  
Connect to the Web App on port 3000:

  http://"web server ip":3000/
  
  

