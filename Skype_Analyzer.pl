#!/usr/bin/perl
use strict;
use File::Basename;
use DBI;

###############################################################
#File: skype_analyser.pl
#Version: 0.2
#Authors: Matt Anderson, Stacey Francoeur, Wesly Delva
#Date: 5/3/2013
#Summary: Analyzes Skype SQLite database file main.db
#and returns information about the Skype user's chat history
###############################################################

#Variables#
my $OSflag = 0; #0 Windows 1 Linux/Mac
my $startDir = "";
my $infinite = 0;
my $loop = 0;
my $invalid = 0;
my $count = 0;
my $user = "No User Selected";
my $option = 0;
my $skypeDir = "";
my $dbh; #Database handle object for SQLite interactions
my $sth; #Statement handle object for SQLite interactions

#Check OS
if ( $^O =~ /^MSWin/ ){
        $OSflag = 0;
} else {
        $OSflag = 1;
}
#Get current directory
$startDir = dirname(__FILE__);

#Infinite Loop, this exits the script if ended
while ($infinite == 0){
        #Glory to Functions!
        main();
}

########FUNCTIONS########
##########BELOW##########

##Main
sub main {
        #Main Menu Option Select Loop
        while ($loop == 0){
                if ($OSflag == 0 ){
                        system('cls');
                } else {
                        system('clear');
                }
                
                #Display applicable errors
                if ($invalid == 1){
                        print "\n! - Invalid Option. That option doesn't exist.\n";
                } elsif ($invalid ==2){
                        print "\n! - Invalid Option. You must select a User first.\n";
                }
                
                #Main Menu Displays
                print "\n";
                print "Skype Analyzer\n";
                print "Main Menu\n";
                print "Current Account: $user \n";
                print "---------\n\n";
                print "Choose an option # or type 'help'\n";
                print "1 - Choose User Account\n";
                print "2 - Display User's Contacts\n";
                print "3 - Display Chat History\n";
                print "4 - Output Chat History to File\n";
                print "5 - Exit\n";
        
                #Accept Input
                print "\nOption #: ";
                $option = <STDIN>;
                chomp($option);
        
                #Determine Option Result
                if ($option !~ /^[1-5]$/ && $option ne "help"){
                        $invalid = 1;
                } else {
                        $loop = 1;
                }
        }
        #Reset Values
        $loop = 0;
        $invalid = 0;
        
        #Go to selected Option's function
        #Choose User
        if ($option == 1){
                selectUser();
        }
        #Display User's Contacts
        elsif ($option == 2){
                #Check they've selected a User
                if ($user =~ /^No User Selected$/){
                        $invalid = 2;
                } else {
                        listContacts();
                }
        }
        #Display User's Chat Logs
        elsif ($option == 3){
                #Check they've selected a User
                if ($user =~ /^No User Selected$/){
                        $invalid = 2;
                } else {
                        displayChat();
                }
        }
        #Output User's Chat Logs to File 
        elsif ($option == 4){
                #Check they've selected a User
                if ($user =~ /^No User Selected$/){
                        $invalid = 2;
                } else {
                        outputChat();
                }
        }
        elsif ($option == 5){
                if ($OSflag == 0 ){
                        system('cls');
                } else {
                        system('clear');
                }
                print "\nBye\n";
                $infinite = 1;
        }
        elsif ($option eq "help"){
                print "\nSo I heard you need help... \n\n";
                print "You should start by selecting option 1\n";
                print "and choosing a directory where the Skype\n";
                print "main.db file is located.\n";
                print "\nPress Enter to Continue";
                my $pause = <STDIN>;
        }
        else {
                print "How did you get here?\n\n";
                my $pause = <STDIN>;
        }
}

#Selects the User to examine
#Requires access to the User's main.db file
sub selectUser {
        #Loop until valid input
        while ($loop == 0){
                if ($OSflag == 0 ){
                        system('cls');
                } else {
                        system('clear');
                }
                
                #Display applicable errors
                if ($invalid == 1){
                        print "\n! - Invalid Option. That Directory doesn't exist.\n";
                        print "Directory Given: $skypeDir\n";
                } elsif ($invalid ==2){
                        print "\n! - Invalid Option. Doesn't contain a Skype main.db file.\n";
                        print "Directory Given: $skypeDir\n";
                }
                
                #Display Information
                print "\nSkype Analyzer\n";
                print "Input the directory containing the Skype Account's Information.\n";
                print "---------\n\n";
                print "Common Local Machine Locations:\n";
                print "Windows XP & Vista: \n'C:/Documents and Settings/<Windows Username>/Application Data/Skype/<Skype Account Name>'\n";
                print "\nWindows 7 & 8: \n'C:/Users/<Windows Username>/AppData/Roaming/Skype/<Skype Account Name>'\n";
                print "\n";
                
                #Accept Input
                print "Dir: ";
                $skypeDir = <STDIN>;
                chomp($skypeDir);
                
                #Check that the Directory Exists and main.db is within
                if ( chdir($skypeDir) ){
                        if ( -e "main.db" ){
                                #Connect to Database
                                $dbh = DBI ->connect("dbi:SQLite:dbname=main.db","","", { RaiseError => 1 }, ) or die $DBI::errstr;
                                
                                #Obtain Skype Name
                                $sth = $dbh->prepare("SELECT skypename FROM accounts;");
                                $sth->execute();
                                my $temp = $sth->fetch();
                                $user = "@$temp";
                                
                                #Disconnect from Database
                                $sth->finish();
                                $dbh->disconnect();
                                
                                #Exit Loop
                                $loop = 1;
                        } else {
                                $invalid = 2;
                        }
                } else {
                        $invalid = 1;
                }
        }
        #Reset Values
        $loop = 0;
        $invalid = 0;
}

#Show Contacts of the Skype User
sub listContacts {
        if ($OSflag == 0 ){
                system('cls');
        } else {
                system('clear');
        }
        
        #Connect to Database
        $dbh = DBI ->connect("dbi:SQLite:dbname=main.db","","", { RaiseError => 1 }, ) or die "Can't connect to database: $DBI::errstr";
        
        #Obtain Contacts List Information
        $sth = $dbh->prepare("SELECT skypename, displayname FROM Contacts WHERE is_permanent = 1;");
        $sth->execute();
        
        #Display Contacts List Information
        #$sth->dump_results();
        my $all = $sth->fetchall_arrayref();
        
        foreach my $row (@$all){
                my ($skypename, $displayname) = @$row;
                print "Username: $skypename \nDisplayname: $displayname\n\n";
                #Prevent Overflow
                $count = $count + 1;
                if ($count == 10){
                        $count = 0;
                        print "Press Enter to Continue\n";
                        my $pause = <STDIN>;
                }
        }
        #Reset Count
        $count = 0;
        
        #Disconnect from Database
        $sth->finish();
        $dbh->disconnect();
        
        print "Press Enter to Continue";
        my $pause = <STDIN>;
}

#Show the Chat Logs of the Skype User
sub displayChat {
        if ($OSflag == 0 ){
                system('cls');
        } else {
                system('clear');
        }
        
        #Connect to Database
        $dbh = DBI ->connect("dbi:SQLite:dbname=main.db","","", { RaiseError => 1 }, ) or die "Can't connect to database: $DBI::errstr";
        
        #Obtain Contacts List Information
        $sth = $dbh->prepare("SELECT dialog_partner, datetime(timestamp,'unixepoch','localtime'), author, body_xml FROM Messages ORDER BY timestamp;");
        $sth->execute();
        
        #Display Contacts List Information
        #$sth->dump_results();
        my $all = $sth->fetchall_arrayref();
        
        foreach my $row (@$all){
                my ($partner, $timestamp, $author, $message) = @$row;
                print "======================\n\n";
                print "Time Sent: $timestamp\n";
                print "Chat Partner: $partner\n";
                print "Message Author: $author\n";
                print "Message Contents: $message\n\n";
                #Prevent Overflow
                $count = $count + 1;
                if ($count == 10){
                        $count = 0;
                        print "======================\n\n";
                        print "Press Enter to Continue\n";
                        my $pause = <STDIN>;
                }
        }
        #Reset Count
        $count = 0;
        
        #Disconnect from Database
        $sth->finish();
        $dbh->disconnect();
        
        print "Press Enter to Continue";
        my $pause = <STDIN>;
}

#Show the Chat Logs of the Skype User
sub outputChat {
        if ($OSflag == 0 ){
                system('cls');
        } else {
                system('clear');
        }
        
        #Connect to Database
        $dbh = DBI ->connect("dbi:SQLite:dbname=main.db","","", { RaiseError => 1 }, ) or die "Can't connect to database: $DBI::errstr";
        
        #Obtain Contacts List Information
        $sth = $dbh->prepare("SELECT dialog_partner, datetime(timestamp,'unixepoch','localtime'), author, body_xml FROM Messages ORDER BY timestamp;");
        $sth->execute();
        
        #Display Contacts List Information
        #$sth->dump_results();
        my $all = $sth->fetchall_arrayref();
        
        #Output log to file at scripts location
        chdir($startDir);
        open (OUTFILE, '>'.$user.'_FullChatHistory.txt');
        
        foreach my $row (@$all){
                my ($partner, $timestamp, $author, $message) = @$row;
                print OUTFILE "======================\n\n";
                print OUTFILE "Time Sent: $timestamp\n";
                print OUTFILE "Chat Partner: $partner\n";
                print OUTFILE "Message Author: $author\n";
                print OUTFILE "Message Contents: $message\n\n";
        }
        
        print "Chat Logs have been saved to:\n";
        print "$startDir".$user."_FullChatHistory.txt\n\n";
        close (OUTFILE);
        #Change back to the directory containing the main.db file
        chdir($skypeDir);
        
        #Disconnect from Database
        $sth->finish();
        $dbh->disconnect();
        
        print "Press Enter to Continue";
        my $pause = <STDIN>;
}
Hide details
Change log
r6 by mwa6...@g.rit.edu on May 7 (3 days ago)   Diff
  * Added OS detection to ensure proper
clearing of screen
  * Added new option to output entire chat
log to a file where the script is located
  * Added some directory detection
  * Adjusted some wording
Go to: 	
Older revisions
 r5 by mwa6...@g.rit.edu on May 6 (4 days ago)   Diff 
 r4 by mwa6...@g.rit.edu on May 3, 2013   Diff 
 r3 by mwa6...@g.rit.edu on May 3, 2013   Diff 
All revisions of this file
File info
Size: 8272 bytes, 342 lines
View raw file
