#!/usr/bin/perl
#
# file_upload.pl - Demonstration script for file uploads
# over HTML form.
#
# This script should function as is.  Copy the file into
# a CGI directory, set the execute permissions, and point
# your browser to it. Then modify if to do something
# useful.
#
# Author: Kyle Dent
# Date: 3/15/01
#
# http://www.seaglass.com/file-upload-pl.html
# http://www.seaglass.com/downloads/file_upload.pl
#

use CGI;
use strict;

my $PROGNAME = "up.pl";
my $BASEDIR = "/var/www/html/";

my $cgi = new CGI();

print "Content-type: text/html\n\n";

#
# If we're invoked directly, display the form and get out.
#
if (! $cgi->param("upfile") ) {
        DisplayForm();
        exit;
}

#
# We're invoked from the form. Get the filename/handle.
#
my $upfile = $cgi->param('upfile');

#
# Get the basename in case we want to use it.
#
my $basename = GetBasename($upfile);

#
# At this point, do whatever we want with the file.
#
# We are going to use the scalar $upfile as a filehandle,
# but perl will complain so we turn off ref checking.
# The newer CGI::upload() function obviates the need for
# this. In new versions do $fh = $cgi->upload('upfile'); 
# to get a legitimate, clean filehandle.
#
no strict 'refs';
#my $fh = $cgi->upload('upfile');
#if (! $fh ) {
#       print "Can't get file handle to uploaded file.";
#       exit(-1);
#}

#######################################################
# Choose one of the techniques below to read the file.
# What you do with the contents is, of course, applica-
# tion specific. In these examples, we just write it to
# a temporary file. 
#
# With text files coming from a Windows client, probably
# you will want to strip out the extra linefeeds.
########################################################

#
# Get a handle to some file to store the contents
#
if (! open(OUTFILE, ">$BASEDIR/$basename") ) {
        print "Can't open $BASEDIR/$basename for writing - $!.";
        exit(-1);
}

print <<"HTML";
<html>
<head>
<title>Upload Successful</title>
<style type="text/css">
body { font-family: Arial, Tahoma; font-size: 12px; color: #000000; line-height: 120%; text-align: center; background-color: #FDFBF9 }
form { margin-top: 0px; margin-bottom: 0px }
input { font-family: Arial, Tahoma; font-size: 12px; height:20px; background-color: #f8f8f8; border: 1px solid #999999 }
</style>
</head>
<body>
<center>
HTML

# give some feedback to browser
print "Saving the file \"$upfile\" to \"$BASEDIR/$basename\".<br>\n";

#
# 1. If we know it's a text file, strip carriage returns
#    and write it out.
#
#while (<$upfile>) {
# or 
#while (<$fh>) {
#       s/\r//;
#       print OUTFILE "$_";
#}

#
# 2. If it's binary or we're not sure...
#
my $nBytes = 0;
my $totBytes = 0;
my $buffer = "";
# If you're on Windows, you'll need this. Otherwise, it
# has no effect.
binmode(OUTFILE);
binmode($upfile);
#binmode($fh);
while ( $nBytes = read($upfile, $buffer, 1024) ) {
#while ( $nBytes = read($fh, $buffer, 1024) ) {
        print OUTFILE $buffer;
        $totBytes += $nBytes;
}

close(OUTFILE);

#
# Turn ref checking back on.
#
use strict 'refs';

# more lame feedback
print "Your file has been uploaded successfully ($totBytes bytes).<br>\n";
print '<br><a href="javascript:window.location=location">Go Back</a>';

print <<"HTML";
</center>
</body>
</html>
HTML

##############################################
# Subroutines
##############################################

#
# GetBasename - delivers filename portion of a fullpath.
#
sub GetBasename {
        my $fullname = shift;
        my(@parts);

        # check which way our slashes go.
        if ( $fullname =~ /(\\)/ ) {
                @parts = split(/\\/, $fullname);
        } else {
                @parts = split(/\//, $fullname);
        }

        return(pop(@parts));
}

#
# DisplayForm - spits out HTML to display our upload form.
#
sub DisplayForm {
        print <<"HTML";
<html>
<head>
<title>File Upload</title>
<style type="text/css">
body { font-family: Arial, Tahoma; font-size: 12px; color: #000000; line-height: 120%; text-align: center; background-color: #FDFBF9 }
form { margin-top: 0px; margin-bottom: 0px }
input { font-family: Arial, Tahoma; font-size: 12px; height:20px; background-color: #f8f8f8; border: 1px solid #999999 }
</style>
</head>
<body>
<center>
  <form id="FileForm" name="FileForm" method="POST" action="$PROGNAME" enctype="multipart/form-data" onsubmit="javascript:return UploadCheck(this);">
    <input id="upfile" name="upfile" type="file" size="60">
    <input id="button" name="button" type="submit" value="Upload">
  </form>
<SCRIPT language="javascript">
var cu = 0;
function UploadStatus()
{
        if (cu%4 == 0)
                FileForm.button.value = "Uploading.";
        else if (cu%4 == 1)
                FileForm.button.value = "Uploading..";
        else if (cu%4 == 2)
                FileForm.button.value = "Uploading...";
        else
                FileForm.button.value = "Uploading";
        cu++;
        setTimeout("UploadStatus();", 1000);
}
function UploadCheck()
{
        if (FileForm.upfile.value != "")
        {
                FileForm.button.disabled = true;
                UploadStatus();
                return true;
        }
        alert("Please select a file to upload!");
        return false;
}
</SCRIPT>
</center>
</body>
</html>
HTML
}
