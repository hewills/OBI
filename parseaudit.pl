#!/sdc1/oracle/Middleware/Oracle_BI1/perl/bin/perl
# Parse log file for loading into OBI audit table
#Note: Takes filename to parse as parameter  (ex. perl parselog.pl myfile1.log)

use warnings;
use strict;
use POSIX;
use DBI;

#Initialization
my $time=""; my $txt=""; my $mod=""; my $date=""; my $sth = "";
my $i=""; my $i2=""; my $user=""; my $detail=""; my $ip="";

my $has_detail=0; my $has_user=0; my $has_ip=0;
my $count = 0; my $firstline = 0;my $statement = 0;
my $logfile="";

#Connect to Database
my $dbh = DBI->connect( 'dbi:Oracle:host=hostname;sid=sidName;port=1521','username','password') 
|| die "Database connection not made: $DBI::errstr";

#File for writing
#my $filename = '/sdc1/oracle/auditparse.txt';
#open (my $fh, '>', $filename) or die "Could not open file.";
# -----------------------------

#Files to parse
my $path = '/sdc1/oracle/Middleware/instances/instance1/diagnostics/logs/OracleBIPresentationServicesComponent/coreapplication_obips1/ACL';
my $fullpath = "$path/$ARGV[0]";  #File to parse. Takes filename as parameter

#File to Parse
open (FILE, $fullpath) or die "Can't open '$fullpath': $!";
# -----------------------------

while (<FILE>) {
      
	chomp;
        
        #Track what line I'm on
        $count = $count + 1;
       
	my $line = "$_\n";
	
        #Parse first line for time, module name, and text
	if ($count == 1) {
		
	    #replace ] with comma and [ with blank, to create comma-delimited .csv		
	    $line =~ tr/[/ /;
	    $line =~ tr/]/,/;
	    #$line =~ tr/ //ds;  #Remove spaces from first line
	    
	    #Pull out date/time 
	    #(different for the very first line, because oracle creates silly files)
            if ($firstline == 0) {
                 
                  $date = substr $line,4,10;
                  $time = substr $line,15,18;
                  
                  #Pull out module -----------------
                  $i = index($line,'saw');   #string index locations
                  $i2 = index($line,'ecid');            
                  $mod = substr $line, $i, $i2-60;  #string length
                  $mod =~ tr/ //ds;   #remove spaces in module name
                  # --------------------------------          
            
                  $firstline = 1;
            } 
            else
            {  
                  $date = substr $line,1,10;
                  $time = substr $line,12,18;
               
                  #Pull out module -----------------
                  $i = index($line,'saw');   #string index locations
                  $i2 = index($line,'ecid');            
                  $mod = substr $line, $i, $i2-57;  #string length
                  $mod =~ tr/ //ds;   #remove spaces in module name
                  # --------------------------------
            }
            
            #Pull out text ---------------------
            $i = rindex($line,','); #find last comma at the end (work?)
            $txt = substr $line, $i;
            $txt =~ tr/\n'//d;  #Remove commas,quotes,ect..
            $txt =~ tr/\n,//d;
            $txt =~ tr/\n"//d;
            # ----------------------------------

            #Print to File
           # print $fh $date; print $fh "\n";
           # print $fh $time; print $fh "\n";
           # print $fh $mod;  print $fh "\n";    
           # print $fh $txt;  print $fh "\n";   
        }
        
      #Print User
      if (/AuthProps/) {
            $i = index($line,'User=');   #string index locations
            $user = substr $line, $i+5;
           # print $fh $user; 
            $has_user = 1;   #Will need to print a default if 0
       }

      #Print IP
      if (/RemoteIP:/) {
            $i = index($line,'RemoteIP:');   #string index locations
            $ip = substr $line, $i+10;
          #  print $fh $ip;
            $has_ip = 1;  #Will need to print a default if 0
       }
       
      #Print dest= and paths=
      if (/HttpArgs:/) {
            $detail = $line;
            $detail =~ tr/\n'//d;  #Remove commas,quotes,ect..
            $detail =~ tr/\n,//d;
            $detail =~ tr/\n"//d;
          #  print $fh $detail;
          #  print $fh "\n"; 
            $has_detail = 1;  #Will need to print a default if 0
      }
                          
      #Start of new log item
	if (/]]/) {
	    
	     if ($has_user == 0)
	    {   $user = "NoUser";
	    }
	    
	     if ($has_ip == 0)
	    {   $ip = "NoIp";
	    
	    }	    
	    
	    if ($has_detail == 0)
	    {   $detail = "NoDetail";
	    }
	       
	    $has_detail = 0;
	    $has_user = 0;
	    $has_ip = 0;
	     
	    $count = 0;
    
      # --------    
      
      #Remove whitespace/carriage return/line feeds before inserting	
      $date =~ s/\n//g;
	  $date =~ s/\s+$//;
	  $date =~ s/\r|\n//g;
	   $time =~ s/\n//g;
	  $time =~ s/\s+$//;
	  $time =~ s/\r|\n//g;
	  $mod =~ s/\n//g;
	  $mod =~ s/\s+$//;
	  $mod =~ s/\r|\n//g;
	   $txt =~ s/\n//g;
	  $txt =~ s/\s+$//;
	  $txt =~ s/\r|\n//g;
	   $user =~ s/\n//g;
	  $user =~ s/\s+$//;
	  $user =~ s/\r|\n//g;
	   $ip =~ s/\n//g;
	  $ip =~ s/\s+$//;
	  $ip =~ s/\r|\n//g;
	   $detail =~ s/\n//g;
	  $detail =~ s/\s+$//;
	  $detail =~ s/\r|\n//g;
      #Check if row already exists. Only load if count is zero.  
      $sth = $dbh->prepare(qq{SELECT COUNT(*) FROM <tablename> WHERE EVENTDATE='$date' and EVENTTIME='$time' and MODULE='$mod'});
      
      #and TEXT='$txt' and USERNAME='$user' and IP='$ip' and DETAIL='$detail'});  # ??? Need this?
      
	  $sth->execute();
	      
      #Insert new rows into the table
      if ($sth->fetchrow() == 0) {
    
	#DEBUG
	#printf $date; printf "\n";
	#printf $time; printf "\n";
	#printf $module; printf "\n";
	#printf $txt; printf "\n";
	#printf $user; printf "\n";
	#printf $ip; printf "\n";
	#printf $detail; printf "\n";
	
         #Don't insert row for non-user (ie. system) events             
         if ($user ne 'NoUser') {            
            $statement = $dbh->do('INSERT INTO <tablename> (EVENTDATE,EVENTTIME,MODULE,TEXT,USERNAME,IP,DETAIL,LOAD_DTTM) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',undef, $date, $time, $mod, $txt, $user, $ip, $detail, strftime("%d-%b-%y %I:%M:%S\n", localtime(time)));
          
				if (!$statement) {
				
				#Write to logfile 
				my $path = "/home/oracle/";
				my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
				$year += 1900;
				$mon++;
				my $currdate = "$mon$mday$year";
				$logfile = $path . "/auditlog_err_$currdate.log";
				open (OUT, ">>$logfile");
				print OUT "Error while inserting SQL- $dbh->errstr \n";
				close(OUT);
				
				die "Error executing SQL Insert - $dbh->errstr";
       				
				} 
		}				
      }
      $sth->finish;
      
    }  #End of new log item	    
           
      # print $fh $line;    #DEBUG Write every line to the file	
}      

close (FILE);
#close ($fh);
$dbh->disconnect; #Close database connection
printf "Parsing/Insert done. \n";  #print to screen
