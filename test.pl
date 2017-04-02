#!/usr/bin/perl

$text = qx(ps -A -o pid);
$superstr = "";

@arr = split(/\s+/, $text);
$size = scalar @arr;

$superstr .= "PID       Name       Location\n";
$superstr .= "---       ----       --------\n";
for (my $i = 2; $i < $size; $i++)
{
  $name =  qx(cat /proc/$arr[$i]/status | awk '/Name:/{print \$2}');
 # $man  =  qx(man $name);
 # $temp =  qx(head -7 <<< $man);
 # $line =  qx(grep $name <<< $temp);
 # $description = qx(awk '/$name -/{\$1=\$2=""; print \$0}' <<< $line);
  $location = qx(sudo realpath /proc/$arr[$i]/exe); 
  $superstr .= $arr[$i]."       ".$name."       ".$location."\n";
}

print $superstr;



