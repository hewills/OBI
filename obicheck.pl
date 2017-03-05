#!/sdc1/oracle/Middleware/Oracle_BI1/perl/bin/perl
#use strict
use warnings;
use Mail::Sender;

#Queries the average load of the server, for the past 30 min., and sends an email if the load hits above 5

my $filename = '/tmp/sar_obi_report.log';
my $loadfile = '/home/oracle/bin/obi_load_report.log';
my $To='list of emails';

my $today = `date`;

#Create sar log report of server load for past 30 min.
qx(sar -q -s `date +"%T" -d "30 min ago"` > /tmp/sar_obi_report.log);

#Search sar report for 5-min averages larger than 5, ignore the header, and print those lines
$searchfile = `awk '{T=\$5; if (T > 5.00 && T != "ldavg-5" && T != "ldavg-15") {print}}' /tmp/sar_obi_report.log`;

#If search finds results, email the entire "30 min." report
if (length($searchfile) != 0) {
	
	#read temp sar report
	my $report;
	open(my $fh, '<', $filename) or die "Cannot open file $filename";
	{	local $/;
		$report = <$fh>;
	}
	close($fh);

	#append high avg to obi load report
	open my $file, '>>', $loadfile or die $!;
	print $file $today . $searchfile;
	close $file;

	$sender = new Mail::Sender {from =>'fromEmail', smtp => 'smtmpServer'};
	$sender->Open({to =>$To,subject => 'Server Load Warning',});
	$sender->SendLineEnc("Average Load Report");
	$sender->SendLineEnc("\nHigh average(s) found:\n\n $searchfile");
	$sender->SendLineEnc("\nLOAD REPORT (Last 30 min.):\n\n $report");
	$sender->Close;
}
