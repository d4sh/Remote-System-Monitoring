#!/usr/bin/perl


use NetSNMP::agent (':all');
use NetSNMP::ASN (':all');
use strict;
use warnings;

sub hello_handler {
  my ($handler, $registration_info, $request_info, $requests) = @_;
  my $request;
  my $PIDstatus = "placeholder";
  my $memInfo = "placeholder2";
  my $cpuinfo = "placeholder3";


  for($request = $requests; $request; $request = $request->next()) {
    my $oid = $request->getOID();
    if ($request_info->getMode() == MODE_GET) {
      if ($oid == new NetSNMP::OID(".1.3.6.1.3.1.0")) {
	my $resultStr = "";
 	my $pids = qx(ps -A -o pid);
  	my @arr = split(/\s+/, $pids);
  	$size = scalar @arr;
  	for (my $i = 2; $i < $size; $i++)
  	{
  	  $name =  qx(cat /proc/$arr[$i]/status | awk '/Name:/{print \$2}');
  	  $resultStr .= $arr[$i]." ".$name."\n";
  	}

	$request->setValue(ASN_OCTET_STR, $cpuinfo);
      }
      elsif ($oid == new NetSNMP::OID(".1.3.6.1.3.1.1")) {
        $request->setValue(ASN_OCTET_STR, $memInfo);
      }elsif ($oid == new NetSNMP::OID(".1.3.6.1.3.1.2")) {
        $request->setValue(ASN_OCTET_STR, $PIDstatus);
      }
    } elsif ($request_info->getMode() == MODE_GETNEXT) {
      if ($oid == new NetSNMP::OID(".1.3.6.1.3.1.0")) {
        $request->setOID(".1.3.6.1.3.1.1");
        $request->setValue(ASN_OCTET_STR, $memInfo);
      }
      elsif ($oid == new NetSNMP::OID(".1.3.6.1.3.1.1")) {
        $request->setOID(".1.3.6.1.3.1.2");
        $request->setValue(ASN_OCTET_STR, $PIDstatus);
      }
      elsif ($oid < new NetSNMP::OID(".1.3.6.1.3.1.0")) {
        $request->setOID(".1.3.6.1.3.1.0");
        $request->setValue(ASN_OCTET_STR, $cpuinfo);
      }
    }
  }
}

my $agent = new NetSNMP::agent();
$agent->register("hello", ".1.3.6.1.3",
                 \&hello_handler);
