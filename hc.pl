#Unix Health Check
#Jason Thomas
##########################################

use strict;
use warnings;
use diagnostics;
use Sys::Hostname;
use File::Find;

my $host = hostname;
my ($UnameA, $OS, $Rel, $Manufacturer);
my ($HAFile, $VCSVER, $CLUSNAME, $CLUSNODES, $NODE0, $NODE1, $NODE0ID, $NODE1ID, $NODE0STAT, $NODE1STAT);
my ($MaxDays, $GetUptime, $SysUp, $TimeCount, $hrs, $min, $CurrentTime, $GetUptime1);
my (%CheckName, %CheckDescription, %CheckSeverity, %CheckDetails, %CheckTrigger, %CheckScore, %CheckResults);
my (%HDU, %HIU);
my (%CheckCritical, %CheckFailed, %CheckWarning);
my ($Filesystem, $Junk, $PercentUsed, $PercentUsedR, $MountPoint);
my ($PercentIUsedR, $PercentIUsed, $Directory);
my ($Count, $File, $Size, $CURMONTH);
my $CurrentUptime;
my ($line, $line2, $cmd, $cmd2, $Loop, $Cores);
my (@files, @return, @array);
my $StatusFile;
my $CURDAY;
my ($PassCount, $ShadCount, $Paaf, $ShadF);
my ($ErrorCount, $OldErrorCount);
my $file;
my ($NPROCSetting, $User);
my $UserProcCount;
my ($NFSMounts, $NFSPath);
my @VCSChecks;
my ($Application, $ApplicationMon, $ApplicationStart, $ApplicationStop, $Applications);
my $NetCommand;
my $ExcludeNFS;
my $TestFC;
my ($EtrustLog1, $EtrustLog2);
my $TotalScore=0;
my $CheckCount=0;
my ($CPUCount, $Memory, $HardwareReport, $Kernel);

$CURDAY=qx(date +%Y-%m-%d-%H:%M);
$CURMONTH=qx(date +%b);

system("mv -f /var/tmp/$host.status.txt /tmp/");
open ( $StatusFile, '>', "/var/tmp/$host.status.txt") or die "Cannot open $StatusFile : $!";
print $StatusFile "$host||$CURDAY";
print $StatusFile "Check||Result||Details||CheckScore \n"; 

#			Passed	Warning	Failed	Critical
#Low		2	2	8	16	24
#Medium		3	3	12	24	36
#High		5	5	20	40	60
#Critical	7	7	28	56	84

my $PassedScore = 1;
my $WarningScore = 4;
my $FailedScore = 8;
my $CriticalScore = 12;
my $SeverityLow = 2;
my $SeverityMedium = 3;
my $SeverityHigh = 5;
my $SeverityCritical = 7;

sub trim
{
  if($_[0])
   {
    $_[0]=~s/^\s+//;
    $_[0]=~s/\s+S//;
    $_[0]=~s/"//;
    $_[0]=~s/,//;
   }
  return
}

sub OSDetect
{
 my $UnameA = qx(uname -a);
 print "$UnameA";
 if (index($UnameA, "AIX") != -1)
  {
   $OS="AIX";
   $Rel=qx(oslevel);
   trim($Rel);
  }
 if (index($UnameA, "Linux") != -1)
  {
   $OS="Linux";
   if (index($UnameA, "el7") != -1)
    {
     $Rel="7";
    }
   if (index($UnameA, "el5") != -1)
    {
     $Rel="5";
    }
   else
    {
     $Rel="6";
    }
  }
 if (index($UnameA, "SunOS") != -1)
  {
   $OS="SunOS";
   $Rel=qx(showrev | grep Release | cut -d'.' -f2);
   trim($Rel);
  }
}

OSDetect;
close $StatusFile;
