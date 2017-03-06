# OBI scripts

## python searchfiles.py

This script can be used on the OBI servers to search an XML file or files, for a particular string.

**Parameters:**  

**all** - Include 'no matches'    
~~~
This parameter will return a list of ALL the file names searched.  
Even if they don't contain a match to the string.  
~~~

**quiet** - No screen ouput.  
~~~
Normally the screen will print "File 1 of 2000".   
This parameter will show nothing as it runs.  
~~~

Wildcards available at prompts: (http://docs.python.org/2/library/re.html)  
~~~
. - any one character except a newline.  
? - preceding element is optional.  
* - matches 0 or more instances of the previous element.  
~~~

**To Run:**  
~~~
1. Browse to /sdc1/oracle/  
2. At the prompt:  python searchfiles.py    
				OR if using a parameter: python searchfiles.py all  OR  python searchfiles.py quiet  
3. You will then be prompted for starting directory, file name, and search string--  
Example Starting Directory: /sdc1/oracle/Middleware  (it does a recursive searching starting here)  
Example File Name: *.xml  
Example Search String: HR/Finance  
~~~

The results are sent to a text file, saved in the 'Starting Directory' you entered.  
Example of what gets returned in the text file:  

~~~
Results for /sdc1/oracle/Middleware/hsu_custom/customMessages/l_en/CompanyName.xml: 
Line #1 Found: 	<WebMessage name="kmsgHeaderSearchCaption"><TEXT>HR/Finance Refresh: 
08/30/2013 08:12:13AM&#160;&#160;&#160;&#160;&#160;|&#160;&#160;&#160;&#160;&#160;Student Refresh: 08/30/2013 08:09:13AM
&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Search</TEXT>

End Search Results
~~~

===

## Audit scripts (parsejazn.pl and parseaudit.pl)

Scripts are saved in /home/oracle/bin.  
Script error logs save to /home/oracle/  

**To trunc/insert the custom OBI roles table**
Parse OBI security file (system-jazn-data.xml), and write roles to a db table.    
~~~
cd /sdc1/oracle/Middleware/Oracle_BI1/perl/bin  
./perl /home/oracle/bin/parsejazn.pl  
~~~

**To update the custom OBI audit table (Requires one log name as a parameter).**  
Parse oracle ACL (Access Control List) log and write to a db table.  
ACL is setup to capture OBIEE catalog changes.   
~~~
cd /sdc1/oracle/Middleware/Oracle_BI1/perl/bin
./perl /home/oracle/bin/parseaudit.pl delete0.log
./perl /home/oracle/bin/parseaudit.pl perm0.log
~~~

===

## RPD_Convert.hta

This program converts oracle RPD binary files into UML, and vice-versa.  

===

## obicheck.pl

This script checks the cpu load on a unix server, and sends an email if a certain limit is reached.  
Script is schedule via crontab.  

===
