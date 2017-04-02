#!/usr/bin/perl


use NetSNMP::agent (':all');
use NetSNMP::ASN (':all');
use strict;
use warnings;

sub hello_handler {
  my ($handler, $registration_info, $request_info, $requests) = @_;
  my $request;
  my $string_value = "hello world";
  my $integer_value = "8675309";
  my $cust_str = "this is a string";

  my $cpuinfo = qx(cat /proc/cpuinfo);
  my $PIDstatus = qx(cat /proc/1043/status);
  my $memInfo = qx(cat /proc/meminfo);

  for($request = $requests; $request; $request = $request->next()) {
    my $oid = $request->getOID();
    if ($request_info->getMode() == MODE_GET) {
      if ($oid == new NetSNMP::OID(".1.3.6.1.3.1.0")) {
         
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
