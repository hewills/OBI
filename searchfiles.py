#!/usr/bin/python
print "\n--------------- Search File Script ----------------"
print "\n Parameters:"
print "   	all - Include 'no matches'"
print "   	quiet - No screen ouput"
print "\n Wildcards: (http://docs.python.org/2/library/re.html)"
print "     . - any one character except a newline."
print "     ? - preceding element is optional."
print "     * - matches 0 or more instances of the previous element."
print "     To Run:  ./searchfiles.py"
print "\n---------------------------------------------------"

import os, fnmatch, re, sys

v_quiet = 0
v_all = 0

for x in range(len(sys.argv)):
	paramlist = sys.argv[x]
	if sys.argv[x] == 'all': v_all = 1
	if sys.argv[x] == 'quiet': v_quiet = 1
	
directory = raw_input("Enter starting directory: ")
filenames = raw_input("Enter file name to search: ")
searchstring = raw_input("Enter search string: ")
print "\n"

f = open(directory + '/searchresults.txt', 'w')
f.write('** Search Results **\n')
f.write('Directory: ')
f.write(directory)
f.write('\nFile Name: ')
f.write(filenames)
f.write('\nSearch String: ')
f.write(searchstring)
f.write('\nParameters: ')

for paramlist in sys.argv:
	f.write(str(paramlist) + ' ')

f.write('\n')
f.write('****************************\n\n')

# define locate function
def locate(pattern, root):
		for path, dirs, files in os.walk(os.path.abspath(root)):
			for filename in fnmatch.filter(files, pattern):
				yield os.path.join(path,filename)
# end function

totalfiles = 0
total = 0

#Count the number of files to be searched, for the user
for filesearch2 in locate(filenames,directory):
	totalfiles = totalfiles + 1	

for filesearch in locate(filenames,directory):
	total = total + 1  #Tracking file count
	#Open file that matches search string
	file_to_search = open(filesearch, "r")  
	linecount = 0
	
	for line in file_to_search:   
		#Check file for searchstring. Print to file if found
		#DEBUG  if searchstring in line:
		if re.search(searchstring,line):
			linecount = linecount + 1
			if linecount == 1:
				f.write('\nResults for ' + filesearch + ': \n')
			f.write('Line #' + str(linecount) + ' Found: ' + line)			
	file_to_search.close()
	if linecount == 0 and v_all: f.write('\nResults for ' + filesearch + ': \n' + 'No match found.\n')
	
	#Print file count to the screen
	if not v_quiet:
		print "Searching... " + str(total) + " of " + str(totalfiles)
	
f.write ('\nEnd Search Results')
f.close()

print "\nResults sent to " + directory + "\\searchresults.txt\n"
