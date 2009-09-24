#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN {
    $webguiRoot = "../..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;


my $toVersion = '7.8.0';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
reorganizeAdSpaceProperties($session);
addSubscribableAspect( $session );
addFeaturedPageWiki( $session );
fixEmptyCalendarIcalFeeds( $session );
upgradeToYUI28( $session );

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}
sub upgradeToYUI28 {
    my $session = shift;
    print "\tUpgrading to YUI 2.8... " unless $quiet;

    $session->db->write(
        "UPDATE template SET template = REPLACE(template, 'element-beta.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE template SET template = REPLACE(template, 'element-beta-min.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE template SET templatePacked = REPLACE(templatePacked, 'element-beta.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE template SET templatePacked = REPLACE(templatePacked, 'element-beta-min.js', 'element-min.js')"
    );

    $session->db->write(
        "UPDATE assetData SET extraHeadTags = REPLACE(extraHeadTags, 'element-beta.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTags = REPLACE(extraHeadTags, 'element-beta-min.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTagsPacked = REPLACE(extraHeadTagsPacked, 'element-beta.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTagsPacked = REPLACE(extraHeadTagsPacked, 'element-beta-min.js', 'element-min.js')"
    );

    $session->db->write(
        "UPDATE template SET template = REPLACE(template, 'carousel-beta.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE template SET template = REPLACE(template, 'carousel-beta-min.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE template SET templatePacked = REPLACE(templatePacked, 'carousel-beta.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE template SET templatePacked = REPLACE(templatePacked, 'carousel-beta-min.js', 'carousel-min.js')"
    );

    $session->db->write(
        "UPDATE assetData SET extraHeadTags = REPLACE(extraHeadTags, 'carousel-beta.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTags = REPLACE(extraHeadTags, 'carousel-beta-min.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTagsPacked = REPLACE(extraHeadTagsPacked, 'carousel-beta.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTagsPacked = REPLACE(extraHeadTagsPacked, 'carousel-beta-min.js', 'carousel-min.js')"
    );

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the column for featured wiki pages
sub fixEmptyCalendarIcalFeeds {
    my $session = shift;
    print "\tSetting icalFeeds in the Calendar to the proper default... " unless $quiet;

    $session->db->write( 
        "UPDATE Calendar set icalFeeds='[]' where icalFeeds IS NULL",
    );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the column for featured wiki pages
sub addFeaturedPageWiki {
    my $session = shift;
    print "\tAdding featured pages to the Wiki " unless $quiet;

    $session->db->write( 
        "ALTER TABLE WikiPage ADD COLUMN isFeatured INT(1)",
    );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add tables for the subscribable aspect
sub addSubscribableAspect {
    my $session = shift;
    print "\tAdding Subscribable aspect..." unless $quiet;

    $session->db->write( <<'ESQL' );
CREATE TABLE assetAspect_Subscribable (
    assetId CHAR(22) BINARY NOT NULL,
    revisionDate BIGINT NOT NULL,
    subscriptionGroupId CHAR(22) BINARY,
    subscriptionTemplateId CHAR(22) BINARY,
    skipNotification INT,
    PRIMARY KEY ( assetId, revisionDate )
)
ESQL

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub reorganizeAdSpaceProperties {
    my $session = shift;
    print "\tReorganize AdSpace and Ad Sales properties... " unless $quiet;
    $session->db->write(q|ALTER TABLE adSpace DROP COLUMN costPerClick|);
    $session->db->write(q|ALTER TABLE adSpace DROP COLUMN costPerImpression|);
    $session->db->write(q|ALTER TABLE adSpace DROP COLUMN groupToPurchase|);
    # and here's our code
    print "DONE!\n" unless $quiet;
}

# -------------- DO NOT EDIT BELOW THIS LINE --------------------------------

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = eval { WebGUI::Asset->getImportNode($session)->importPackage( $storage ); };

    if ($package eq 'corrupt') {
        die "Corrupt package found in $file.  Stopping upgrade.\n";
    }
    if ($@ || !defined $package) {
        die "Error during package import on $file: $@\nStopping upgrade\n.";
    }

    # Turn off the package flag, and set the default flag for templates added
    my $assetIds = $package->getLineage( ['self','descendants'] );
    for my $assetId ( @{ $assetIds } ) {
        my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( !$asset ) {
            print "Couldn't instantiate asset with ID '$assetId'. Please check package '$file' for corruption.\n";
            next;
        }
        my $properties = { isPackage => 0 };
        if ($asset->isa('WebGUI::Asset::Template')) {
            $properties->{isDefault} = 1;
        }
        $asset->update( $properties );
    }

    return;
}

#-------------------------------------------------
sub start {
    my $configFile;
    $|=1; #disable output buffering
    GetOptions(
        'configFile=s'=>\$configFile,
        'quiet'=>\$quiet
    );
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name=>"Upgrade to ".$toVersion});
    return $session;
}

#-------------------------------------------------
sub finish {
    my $session = shift;
    updateTemplates($session);
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
    $session->close();
}

#-------------------------------------------------
sub updateTemplates {
    my $session = shift;
    return undef unless (-d "packages-".$toVersion);
    print "\tUpdating packages.\n" unless ($quiet);
    opendir(DIR,"packages-".$toVersion);
    my @files = readdir(DIR);
    closedir(DIR);
    my $newFolder = undef;
    foreach my $file (@files) {
        next unless ($file =~ /\.wgpkg$/);
        # Fix the filename to include a path
        $file       = "packages-" . $toVersion . "/" . $file;
        addPackage( $session, $file );
    }
}

#vim:ft=perl
