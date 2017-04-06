#!/usr/bin/perl

use Cwd qw(abs_path realpath);
use NetSNMP::agent (':all');
use NetSNMP::ASN (':all');
use File::Spec;

sub extension_handler {
  my ($handler, $registration_info, $request_info, $requests) = @_;
  my $request;
  my $PIDstatus = "placeholder";
  my $memInfo = "placeholder2";
  my $sysStr = sysVals();
  my $procStr = initVals();
 
  for($request = $requests; $request; $request = $request->next()) {
    my $oid = $request->getOID();
    if ($request_info->getMode() == MODE_GET) {
      if ($oid == new NetSNMP::OID(".1.3.6.1.3.1.0")) {
	$request->setValue(ASN_OCTET_STR, $procStr);
      }
      elsif ($oid == new NetSNMP::OID(".1.3.6.1.3.1.1")) {
        $request->setValue(ASN_OCTET_STR, $sysStr);
      }elsif ($oid == new NetSNMP::OID(".1.3.6.1.3.1.2")) {
        $request->setValue(ASN_OCTET_STR, $PIDstatus);
      }
    } elsif ($request_info->getMode() == MODE_GETNEXT) {
      if ($oid == new NetSNMP::OID(".1.3.6.1.3.1.0")) {
        $request->setOID(".1.3.6.1.3.1.1");
        $request->setValue(ASN_OCTET_STR, $sysStr);
      }
      elsif ($oid == new NetSNMP::OID(".1.3.6.1.3.1.1")) {
        $request->setOID(".1.3.6.1.3.1.2");
        $request->setValue(ASN_OCTET_STR, $PIDstatus);
      }
      elsif ($oid < new NetSNMP::OID(".1.3.6.1.3.1.0")) {
        $request->setOID(".1.3.6.1.3.1.0");
        $request->setValue(ASN_OCTET_STR, $procStr);
      }
    }
  }
}

sub sysVals {
	#1 desc
	my $resultStr = "";
	my $desc = qx(uname -a);
	$resultStr .= $desc;
	#2 ram
	my $tot = qx(cat /proc/meminfo | awk '/MemTotal: /{print \$2/1024}');
	my $free = qx(cat /proc/meminfo| awk '/MemFree: /{print \$2/1024}');
	$resultStr .= $tot;
	$resultStr .= $free;
	$resultStr .= ($tot - $free);

	return $resultStr;
}

sub initVals {
  my $resultStr = "";
  my $pids = qx(ps -U pi -o pid);
  my @arr = split(/\s+/, $pids);
  my $size = scalar @arr;
  for (my $i = 2; $i < $size; $i++)
  {
    $name = qx(cat /proc/$arr[$i]/status | awk '/Name:/{printf \$2}');
    $ram  = qx(cat /proc/$arr[$i]/status | awk '/VmRSS:/{printf \$2}');
    $ram = $ram / 1024;
    $resultStr .= $arr[$i]." ".$name." ".$ram." "."\n";
  }
  return $resultStr;
}

my $agent = new NetSNMP::agent();
$agent->register("extension", ".1.3.6.1.3",
                 \&extension_handler);
