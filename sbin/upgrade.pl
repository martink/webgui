#!/usr/bin/perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN {
        $webguiRoot = "..";
        unshift (@INC, $webguiRoot."/lib");
}

use DBI;
use Getopt::Long;
use Parse::PlainConfig;
use strict;
use WebGUI::SQL;

my $help;
my $override;
my $quiet;
my $mysql = "/usr/bin/mysql";
my $mysqldump = "/usr/bin/mysqldump";
my $backupDir = "/data/backups";
my $skipBackup;
my $doit;

GetOptions(
        'help'=>\$help,
        'override'=>\$override,
        'quiet'=>\$quiet,
	'mysql=s'=>\$mysql,
	'doit'=>\$doit,
	'mysqldump=s'=>\$mysqldump,
	'backupDir=s'=>\$backupDir,
	'skipbackup'=>\$skipBackup
);


if ($help){
        print <<STOP;


Usage: perl $0 

Options:

	--backupDir	The folder where backups should be
			created. Defaults to '/data/backups'.

        --help          Display this help message and exit.

	--mysql		The path to your mysql client executable.
			Defaults to '/usr/bin/mysql'.

	--mysqldump	The path to your mysqldump executable.
			Defaults to '/usr/bin/mysqldump'.

        --override      This utility is designed to be run as
                        a privileged user on Linux style systems.
                        If you wish to run this utility without
                        being the super user, then use this flag,
                        but note that it may not work as
                        intended.

        --quiet         Disable output unless there's an error.

	--skipBackup	Backups will not be performed during the
			upgrade.

STOP
        exit;
}



unless ($doit) {
	print <<STOP;

+--------------------------------------------------------------------+
|                                                                    |
|                         W  A  R  N  I  N  G                        |
|                                                                    |
+--------------------------------------------------------------------+
|                                                                    |
| There are no guarantees of any kind provided with this software.   |
| This utility has been tested rigorously, and has performed without |
| error or consequence in our labs, and on our production servers    |
| for more than a year. However, there is no substitute for a good   |
| backup of your software and data before performing any kind of     |
| upgrade.                                                           |
|                                                                    |
| NOTE: This utility will work on MySQL databases only. Any          |
| configs using non-MySQL databases will be skipped.                 |
|                                                                    |
+--------------------------------------------------------------------+
|                                                                    |
| For more information about this utility type:                      |
|                                                                    |
| perl upgrade.pl --help                                             |
|                                                                    |
+--------------------------------------------------------------------+
|                                                                    |
| You must include the command line argument "--doit" in your        |
| command in order to bypass this message.                           |
|                                                                    |
+--------------------------------------------------------------------+

STOP
	exit;
}


if (!($^O =~ /^Win/i) && $> != 0 && !$override) {
	print "You must be the super user to use this utility.\n";
	exit;
}

## Globals

$| = 1;
our $perl = $^X;
our $slash;
if ($^O =~ /^Win/i) {
	$slash = "\\";
} else {
	$slash = "/";
}
our $upgradesPath = $webguiRoot.$slash."docs".$slash."upgrades".$slash;
our $configsPath = $webguiRoot.$slash."etc".$slash;
our (%upgrade, %config);


## Find upgrade files.

print "\nLooking for upgrade files...\n" unless ($quiet);
opendir(DIR,$upgradesPath) or die "Couldn't open $upgradesPath\n";
my @files = readdir(DIR);
closedir(DIR);
foreach my $file (@files) {
	if ($file =~ /upgrade_(\d+\.\d+\.\d+)-(\d+\.\d+\.\d+)\.(\w+)/) {
		if (checkVersion($1)) {
			if ($3 eq "sql") {
				print "\tFound upgrade script from $1 to $2.\n" unless ($quiet);
				$upgrade{$1}{sql} = $file;
			} elsif ($3 eq "pl") {
				print "\tFound upgrade executable from $1 to $2.\n" unless ($quiet);
				$upgrade{$1}{pl} = $file;
			}
			$upgrade{$1}{from} = $1;
			$upgrade{$1}{to} = $2;
		}
	}
}

## Find site configs.

print "\nGetting site configs...\n" unless ($quiet);
opendir (DIR,$configsPath) or die "Can't open $configsPath\n";
my @files=readdir(DIR);
closedir(DIR);
foreach my $file (@files) {
	if ($file =~ /(.*?)\.conf$/ && $file ne "some_other_site.conf") {
		print "\tFound $file.\n" unless ($quiet);
		$config{$file}{configFile} = $file;
		my $config = Parse::PlainConfig->new('DELIM' => '=',
                	'FILE' => $configsPath.$config{$file}{configFile},
                	'PURGE' => 1);
		$config{$file}{dsn} = $config->get('dsn');
		my $temp = $config{$file}{dsn};
		$temp =~ s/^DBI\:(.*)$/$1/;
		$temp =~ s/(\w+)\:(.*)/$2/;
		#$config{$file}{dsn} =~ /^DBI\:(\w+)\:(\w+)(\:(.*)|)$/;
		if ($1 eq "mysql") {
			if ($temp =~ /(\w+)\;host=(.*)/) {
				$config{$file}{db} = $1;
				$config{$file}{host} = $2;
			} elsif ($temp =~ /(\w+)\;(.*)/) {
				$config{$file}{db} = $1;
				$config{$file}{host} = $2;
			} elsif ($temp =~ /(\w+)\:(.*)/) {
				$config{$file}{db} = $1;
				$config{$file}{host} = $2;
			} else {
				$config{$file}{db} = $temp;
			}
			$config{$file}{dbuser} = $config->get('dbuser');
			$config{$file}{dbpass} = $config->get('dbpass');
			$config{$file}{mysqlCLI} = $config->get('mysqlCLI');
			$config{$file}{mysqlDump} = $config->get('mysqlDump');
			$config{$file}{backupPath} = $config->get('backupPath');
			my $dbh = DBI->connect($config{$file}{dsn},$config{$file}{dbuser},$config{$file}{dbpass});
			($config{$file}{version}) = WebGUI::SQL->quickArray("select webguiVersion from webguiVersion 
				order by dateApplied desc, webguiVersion desc limit 1",$dbh);
			$dbh->disconnect;
		} else {
			delete $config{$file};
			print "\tSkipping non-MySQL database.\n" unless ($quiet);
		}
	}
}



print "\nREADY TO BEGIN UPGRADES\n" unless ($quiet);

my $notRun = 1;
			
chdir($upgradesPath);
foreach my $config (keys %config) {
	my $clicmd = $config{$config}{mysqlCLI} || $mysql;
	my $dumpcmd = $config{$config}{mysqlDump} || $mysqldump;
	my $backupTo = $config{$config}{backupPath} || $backupDir;
	mkdir($backupTo);
	while ($upgrade{$config{$config}{version}}{sql} ne "") {
		my $upgrade = $upgrade{$config{$config}{version}}{from};
		unless ($skipBackup) {
			print "\n".$config{$config}{db}." ".$upgrade{$upgrade}{from}."-".$upgrade{$upgrade}{to}."\n" unless ($quiet);
			print "\tBacking up $config{$config}{db} ($upgrade{$upgrade}{from})..." unless ($quiet);
			my $cmd = $dumpcmd." -u".$config{$config}{dbuser}." -p".$config{$config}{dbpass};
			$cmd .= " --host=".$config{$config}{host} if ($config{$config}{host});
			$cmd .= " --add-drop-table --databases ".$config{$config}{db}." > "
				.$backupTo.$slash.$config{$config}{db}."_".$upgrade{$upgrade}{from}.".sql";
			unless (system($cmd)) {
				print "OK\n" unless ($quiet);
			} else {
				print "Failed!\n" unless ($quiet);
			}
		}
		print "\tUpgrading to ".$upgrade{$upgrade}{to}."..." unless ($quiet);
		my $cmd = $clicmd." -u".$config{$config}{dbuser}." -p".$config{$config}{dbpass};
		$cmd .= " --host=".$config{$config}{host} if ($config{$config}{host});
		$cmd .= " --database=".$config{$config}{db}." < ".$upgrade{$upgrade}{sql};
		unless (system($cmd)) {
			print "OK\n" unless ($quiet);
		} else {
                	print "Failed!\n" unless ($quiet);
                }
		if ($upgrade{$upgrade}{pl} ne "") {
			my $cmd = $perl." ".$upgrade{$upgrade}{pl}." --configFile=".$config;
			$cmd .= " --quiet" if ($quiet);
			if (system($cmd)) {
				print "\tProcessing upgrade executable failed!\n";
			}
		}
		$config{$config}{version} = $upgrade{$upgrade}{to};
		$notRun = 0;
	}
}

if ($notRun) {
	print "\nNO UPGRADES NECESSARY\n\n" unless ($quiet);
} else {
	unless ($quiet) {
		print <<STOP;

UPGRADES COMPLETE
Please restart your web server and test your sites.

NOTE: If you have not already done so, please consult
docs/gotcha.txt for possible upgrade complications.

STOP
	}
}




#-----------------------------------------
# checkVersion($versionNumber)
#-----------------------------------------
# Version number must be 3.5.1 or greater
# in order to be upgraded by this utility.
#-----------------------------------------
sub checkVersion {
	$_[0] =~ /(\d+)\.(\d+)\.(\d+)/; 
        if ($1 > 3) {
        	return 1;
        } elsif ($1 == 3) {
        	if ($2 > 5) {
                	return 1;
                } elsif ($2 == 5) {
                	if ($3 > 0) {
                        	return 1;
                        } else {
				return 0;
			}
                } else {
			return 0;
		}
        } else {
		return 0;
	}
}





