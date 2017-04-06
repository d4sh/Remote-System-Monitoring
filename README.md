# Remote System Monitoring 

File Setup:
<ul>
<li>public_html folder on Web Server</li>

<li>extension.pl in /usr/local/share/snmp (ROOT access needed)</li>
</ul>

Usage:


add snmp session with your agent using credentials in snmpServer.js
<ul>
  <li>var sessionName = snmp.createSession("agent ip", "community"); 
</ul>

Make sure your SNMP Agent is running: sudo service snmpd start
  
To check if your SNMP Agent is running: ps -ef | grep snmpd
  
  
Start Node.js Server (listerning on port 3000): sudo node snmpServer.js
  
  
Connect to the Web App on port 3000: http://"web server ip":3000/
  
  

