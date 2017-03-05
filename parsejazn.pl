#/sdc1/oracle/Middleware/Oracle_BI1/perl/bin/perl
# Parse XML file and load into OBI roles table

use warnings;
use strict;
# use lib '/sdc1/oracle/Middleware/Oracle_BI1/perl/lib/perl5';
use XML::XPath;
#use Path::Class;
use POSIX;
use DBI;

# Export Log Initialization
# my $dir = dir("/sdc1/oracle/");   #export data location
# my $file = $dir->file("xmlparse.txt");  #export data
# my $file_handle = $file->openw();  #open data file
# -------

#Initialization
my $count = 0;
my $role = '';
my $display = '';
my $username = '';
my $statement = 0;
my $logfile ='';

#Connect to Database
my $dbh = DBI->connect( 'dbi:Oracle:host=hostname;sid=sidName;port=1521','user','password') 
|| die "Database connection not made: $DBI::errstr";

#Clear Table before writing
my $sth = $dbh->prepare("TRUNCATE TABLE <tablename>");
$sth->execute();

# XML file Initialization
my $xp = XML::XPath->new(filename => '/sdc1/oracle/Middleware/user_projects/domains/bifoundation_domain/config/fmwconfig/system-jazn-data.xml'); 
# -------

my $nodeset = $xp->find('//member'); # Find the Member element in the xml

  foreach my $node ($nodeset->get_nodelist) {
      
        #Grab username
        my $user = $node->findvalue('name');
        #printf "User: %s\n", $user;  #Debug
       
        #Move up to app-role parent
        my $parent = $node->getParentNode;
        my $parent2 = $parent->getParentNode;
        
        #Grab role name
        my $role = $parent2->findvalue('name');
        #printf "Role: %s\n", $role;   #Debug      
        
        #Grab display role name
        my $display = $parent2->findvalue('display-name');
        #printf "Display: %s\n", $display; #Debug
        
        #Remove whitespace/carriage return/line feeds before inserting	
            $role =~ s/^\s+//;
            $role =~ s/\s+/ /g;
            $role =~ s/\s+$//;
            $display =~ s/^\s+//;
            $display =~ s/\s+/ /g;
            $display =~ s/\s+$//;
            $user =~ s/^\s+//;
            $user =~ s/\s+/ /g;
            $user =~ s/\s+$//;
        
       #Insert into database     
       $statement = $dbh->do('INSERT INTO <tablename> (ROLE, DISPLAYNAME, USERNAME, LOAD_DTTM) VALUES (?, ?, ?, ?)',
                        undef, $role, $display, $user, strftime("%d-%b-%y %I:%M:%S\n", localtime(time)));
       
       if (!$statement) {

	   #Write to logfile 
       my $path = "/home/oracle/";
       my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
       $year += 1900;
       $mon++;
       my $currdate = "$mon$mday$year";
       $logfile = $path . "/parse_err_$currdate.log";
       open (OUT, ">>$logfile");
       print OUT "There was an error encountered while executing SQL- $dbh->errstr \n";
       close(OUT);
	   
       die "Error executing SQL SELECT - $dbh->errstr";

       }
	   
	   if ($statement eq '0E0') {

	   #Write to logfile 
       my $path = "/home/oracle/";
       my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
       $year += 1900;
       $mon++;
       my $currdate = "$mon$mday$year";
       $logfile = $path . "/parse_warn_$currdate.log";
       open (OUT, ">>$logfile");
       print OUT "No rows inserted/updated.- $dbh->errstr \n";
       close(OUT);
	   
       die "No rows inserted/updated - $dbh->errstr";
       
	   }
     
        #Print to Export file (xmlparse.txt)
        # $file_handle->print($role . "\n");
        # $file_handle->print($display . "\n");
        # $file_handle->print($user . "\n");
        # --------

    }
    
printf "Done. \n";  #print to screen
$dbh->disconnect;
