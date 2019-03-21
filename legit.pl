#!/usr/bin/perl  -w

# COMP2041 Assignment 1 Legit
# z5113067
# 18s2  2/10/2018
# Subset 0 Attempted and Completed.

use strict;
use warnings;
use File::Copy;
use File::Compare;

# Global Variables
our $legit = ".legit"; # Root repository
our $commit_number;    # Commit Number Tracker
our $suffix;           # Last Snapshot Number Tracker

# Runs Code
main();

# Main program reads command-line arguments to execute user requests.
sub main {
  # Usage error
  if(@ARGV == 0){
    usage();
    exit(0);
  }
  # Check whether valid  git command 
  my $git_command = $ARGV[0];
  if(!(valid_command())){
    print STDERR "legit.pl: error: unknown command $ARGV[0]\n";
    usage();
    exit(1);
  }
  # Execute git command
  if($git_command eq "init"){
    initialize_rep();
  }else{
     
    # Check repository is correctly initialized before executing other git commands.
    if(! -d $legit){
      print STDERR "legit.pl: error: no .legit directory containing legit repository exists\n";
      exit(1);
    } 

    # Gets the current commit number and last snapshot number of branch.
    get_variables();

    if($git_command eq "add"){
      add();
    }elsif($git_command eq "commit"){
      commit();
    }elsif($git_command eq "log"){
      get_log();
    }elsif($git_command eq "show"){
      show();
    }else{
      if(@ARGV-1 == 1){
        print STDERR "legit.pl: error: unknown command $ARGV[0]\n";
      }
        usage(); # Returns usage message if not a subset 0 git command. 
    }
  }
  exit(0);
}

# Checks if valid git command from Subset 0
sub valid_command {
  my $command = $ARGV[0];
  if($command eq "init" || $command eq "add" || $command eq "commit" || 
    $command eq "log" || $command eq "show"){
    return 1;
  } return 0;
}

# If user did not enter correct command-line arguments, displays
# how to execute program.
sub usage {
print "Usage: legit.pl <command> [<args>]

These are the legit commands:
   init       Create an empty legit repository
   add        Add file contents to the index
   commit     Record changes to the repository
   log        Show commit log
   show       Show file at particular state
   rm         Remove files from the current directory and from the index
   status     Show the status of files in the current directory, index, and repository
   branch     list, create or delete a branch
   checkout   Switch branches or restore current directory files
   merge      Join two development histories together\n\n";
}

# This function gets the last commit number and snapshot number of branch.
# Helpful to Commit and Show Functions. 
sub get_variables {
  my $line;
    open(FILE,'<', "$legit/last_commit") or die "Can't read 'last_commit' file: $!\n";
    $line = <FILE>;
    $line =~ /^([0-9]+)/;
    $commit_number = $1;
    close FILE; 

    open(FILE,'<',"$legit/snapshots/last_snap") or die "Can't read 'last snap' file: $!\n";
    $line = <FILE>;
    $line =~ /^([0-9]+)/;
    $suffix = $1;
    close FILE;
}

# This function initializes the .legit repository, sub-directories such as 
# index and snapshots, and helper files such as last_commit and last_snap
# so we can keep track of files throughout the life-time of .legit.
sub initialize_rep {

  # Check valid number of arguments
  if(scalar @ARGV > 1){
    print STDERR "usage: legit.pl init\n";
    exit(1);
  }

  # Check .legit directory does not already exist.
  if( -d $legit){
    print STDERR "legit.pl: error: .legit already exists\n";
    exit(1);
  }

  # Create repository and all necessary subdirectories and files
  mkdir($legit);
  mkdir("$legit/index");
  mkdir("$legit/snapshots");
  open F, ">", "$legit/commit_history" or die "Error initializing commit_history file";
  close F;
  open F, ">", "$legit/snapshots/last_snap" or die "Error initializing last_snap file";
     print F "0\n"; #initializes num 0
  close F;
  open F, ">", "$legit/last_commit" or die "Error initializing last_commit file."; 
    print F "0\n"; #initializes num 0
  close F;
 
  # Print success message.
  print "Initialized empty legit repository in .legit\n";
}

# This functions adds one or more files to the index subdirectory. 
# Assumption that the add command will not be given pathnames with slashes. 
# Files should always start with an alphanumeric character ([a-zA-Z0-9]) and will 
# only contain alpha-numeric characters plus '.', '-' and '_' characters.
sub add {

  # Check valid number of arguments
  # Not required to produce this error message but included anyways.
  if(scalar @ARGV < 2){
    print STDERR "legit.pl: error: internal error Nothing specified, nothing added.\n";
    exit(1);
  }

  # For every file
  foreach my $file(@ARGV){
    next if $file eq "add"; # skip git command arguement
    # Check to see if file exists in current directory and is an ordinary file.
    if(-f $file && -e $file){ 
        # Check file name is valid.
        if($file =~ /^-/){
          print STDERR "usage: legit.pl add <filenames>\n";
          exit(1);
        }elsif($file =~ /^_/){
          print STDERR "legit.pl: error: invalid filename '$file'\n";
          exit(1);
        }elsif($file =~ /^[a-zA-Z0-9]?([a-zA-Z0-9\.\-_]+$)/){ 
          # Add file to Index
          copy($file, "$legit/index/$file");
        }
    }else{
      print STDERR "legit.pl: error: can not open '$file'\n";
      exit(1);
    }
  }
}

# This function saves a copy of all files in the index repository.
# It does this by taking a snapshot of the directory and saves it
# in a directory associated with the commit number under the snapshots 
# subdirectory. It also saves the commit in commit_history file with the
# message describing the commit.
sub commit {

  # Check valid arguments

  if(scalar @ARGV != 3){
    print STDERR "usage: legit.pl commit [-a] -m commit-message\n";
    exit(1);
  }
  if($ARGV[1] ne "-m"){
    print STDERR "usage: legit.pl commit [-a] -m commit-message\n";
    exit(1);
  }

  # Check index has files to commit
  my @files = glob("$legit/index/*");
  if($#files < 0 || (!checkFiles())){
    print "nothing to commit\n";
    exit(0);
  }

  # Check if commit_history file has any commits in it already
  my $filename = "$legit/commit_history";
  my $lines = 0;
  open(FILE, $filename) or die "Can't open '$filename': $!";
    $lines++ while(<FILE>);
  close FILE;
  
  if($lines == 0){
    $commit_number = 0;
    $suffix = 0;
  }else{
    $commit_number += 1;
    $suffix = $commit_number;
  }

  # Success message
  print "Committed as commit $commit_number\n";
  # Create snapshot of branch
  create_new_snapshot_directory(@files);

  # Update commit number and last snap variables
  open F, ">>", "$legit/commit_history" or die "Error opening commit history file";
    print F "$commit_number $ARGV[2]\n";
  close F;
    
  open F, ">", "$legit/snapshots/last_snap" or die "Error opening last snap file";
    print F "$suffix\n";
  close F;

  open F, ">", "$legit/last_commit" or die "Error opening last commit file";
    print F "$commit_number\n";
  close F;
  
}

# Helper function for commit function.
# Checks to see if files in index are different
# to files in last snapshot directory.
sub checkFiles{
  my $indexFolder = "$legit/index";
  my $snapshotFolder = "$legit/snapshots/S$suffix";
  my @indexFiles = glob("$indexFolder/*");
  my @snapshotFiles = glob("$snapshotFolder/*");
  
  foreach my $file(@indexFiles){
    $file =~ /\/([a-zA-Z0-9_.\-]+)$/;
    my $fileName = $1;
    chomp $snapshotFolder;
    my $snap = $snapshotFolder."/".$fileName;
    # if file does not exist in snap return false
    if(!(-e "$snap")){
      return 1;
    # if file is same as in index i.e. unchanged return false
    }else{
      if(compare("$file","$snap") != 0){
        return 1;
      }
    }
  }
  return 0;
}

# Helper function for commit function.
# Takes a snapshot of Index subdirectory
# And creates a new snapshot directory in snapshots subdirectory
# with the directory name associated with the commit number.
sub create_new_snapshot_directory{
  my @files = @_; # all of index files
  my $fileName;
  my $directory = "$legit/snapshots/S$suffix";
  $directory =~ s/\s+\z//; #  removes any trailing ? e.g. S1?
  mkdir($directory);
  foreach my $file(@files){
    $file =~ /\/([a-zA-Z0-9_.\-]+)$/;
    $fileName = $1;
    copy($file,"$directory/$fileName");
  }
}

# This function prints one line for every commit that has been made to
# the repository. 
# Assumption is made that commit_history file will never have more than
# one particular commit number. 
sub get_log {
  if(scalar @ARGV > 1){
    print STDERR "usage: legit.pl log\n";
    exit(1);
  }
  # Check if commit_history file has any commits in it already
  my $filename = "$legit/commit_history";
  my $lines = 0;
  open(FILE, $filename) or die "Can't open '$filename': $!";
    $lines++ while(<FILE>);
  close FILE;
  if($lines == 0){
    print STDERR "legit.pl: error: your repository does not have any commits yet\n";
    exit(1);
  }

  my %hash;
  open F, "<", "$legit/commit_history" or die "Error couldn't read commit history file";
  while(my $line = <F>){
    my @content = split(' ', $line,2);
    chomp $content[1]; # commit message
    $hash{$content[0]} = $content[1];
  }
  close F;
  # Reverse order for most recent commit at the top
  foreach my $key(reverse sort keys %hash){
    print "$key $hash{$key}\n";
  }
}

# This function pritns the contents of a specified file
# from the specified commit. 
# If commit is omitted, it prints file from index.
sub show {
  my $snapshot_directory;
  my $directory;
  my $file;

  # Check if commit_history file has any commits in it already
  my $lines = 0;
  open(FILE, "$legit/commit_history") or die "Can't open 'commit_history': $!";
    $lines++ while(<FILE>);
  close FILE;
  
  if($lines == 0){
    print STDERR "legit.pl: error: your repository does not have any commits yet\n";
    exit(1);
  }

  # Check arguments are valid.
  if(scalar @ARGV != 2){
    print STDERR "usage: legit.pl show <commit>:<filename>\n";
    exit(1);
  }elsif($ARGV[1] !~ /:/){
    print STDERR "legit.pl: error: invalid object $ARGV[1]\n";
    exit(1);
  }else{
    # Split command line arguement into commit number and file name
    my @content = split(':',$ARGV[1]);
    # If commit number is ommitted, looks through index subdirectory
    if($content[0] eq ""){
      $snapshot_directory = "$legit/index/";
      $file = $snapshot_directory.$content[1];
      $directory = "index";
    }else{
      $snapshot_directory = "$legit/snapshots/S$content[0]/";
      # Checks to see if valid commit number given
      if(! -d $snapshot_directory){
        print STDERR "legit.pl: error: unknown commit '$content[0]'\n";

        exit(1);
      }
      $file = $snapshot_directory.$content[1];
      $directory = "commit $content[0]";
    }
    # If file does not exist
    if(! -e $file){
      print STDERR "legit.pl: error: '$content[1]' not found in $directory\n";
      exit(1);
    }
    open(FILE,'<', $file) or die "Can't read '$content[1]': $!\n";
      print <FILE>;
    close FILE;
  }
}

