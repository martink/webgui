#!/usr/bin/env perl

$|++; # disable output buffering
our ($webguiRoot, $configFile, $quiet);

BEGIN {
    $webguiRoot = "..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Graphics::Font;
use WebGUI::Graphics::Palette;

use Data::Dumper;

# Get parameters here, including $help
GetOptions(
    'configFile=s'  => \$configFile,
);


my $session = start( $webguiRoot, $configFile );

upgradeFontTable( $session );
upgradePaletteTable( $session );

finish($session);

#----------------------------------------------------------------------------
sub upgradeFontTable {
    my $session = shift;
    print "\tUpgrading font table..." unless $quiet;

    WebGUI::Graphics::Font->crud_createTable( $session );

#    my $sth = $session->db->read( 'select * from imageFont' );
#
#    while ( my $row = $sth->hashRef ) {
#        my $font = WebGUI::Graphics::Font->create( $session );
#        $font->update( {
#            
#    }

    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub upgradePaletteTable {
    my $session = shift;
    my $db      = $session->db;
    print "\tUpgrading palette table..." unless $quiet;

    WebGUI::Graphics::Palette::Persist->crud_createTable( $session );
    WebGUI::Graphics::Palette::Color->crud_createTable( $session );

    my $sth = $db->read( 'select * from imagePalette' );

    while ( my $paletteData = $sth->hashRef ) {
        my $paletteId   = $paletteData->{ paletteId };
        $paletteId      = 'defaultPalette00000001' if $paletteId eq 'defaultPalette';

        my $palette = WebGUI::Graphics::Palette::Persist->create( $session,  
            {
                name    => $paletteData->{ name },
            },
            {
                id      => $paletteId,
            }
        );

        my $colors = $db->read( 
            'select t1.* from imageColor as t1, imagePaletteColors as t2 '
            . ' where t1.colorId=t2.colorId and t2.paletteId=? order by t2.paletteOrder', 
            [
                $paletteData->{ paletteId },
            ]
        );

        while ( my %color = $colors->hash ) {
        #    $color{ fillTriplet   } =~ s/#//;
        #    $color{ strokeTriplet } =~ s/#//;

            $color{ strokeAlpha } = sprintf '%02x', 255 ^ hex $color{ strokeAlpha };
            $color{ fillAlpha   } = sprintf '%02x', 255 ^ hex $color{ fillAlpha   };
            WebGUI::Graphics::Palette::Color->create( $session, {
                %color,
                paletteId   => $paletteId,
            } );
        }

        $colors->finish;


    }

    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub start {
    my $webguiRoot  = shift;
    my $configFile  = shift;
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    
    ## If your script is adding or changing content you need these lines, otherwise leave them commented
    #
    # my $versionTag = WebGUI::VersionTag->getWorking($session);
    # $versionTag->set({name => 'Name Your Tag'});
    #
    ##
    
    return $session;
}

#----------------------------------------------------------------------------
sub finish {
    my $session = shift;
    
    ## If your script is adding or changing content you need these lines, otherwise leave them commented
    #
    # my $versionTag = WebGUI::VersionTag->getWorking($session);
    # $versionTag->commit;
    ##
    
    $session->var->end;
    $session->close;
}

__END__


=head1 NAME

utility - A template for WebGUI utility scripts

=head1 SYNOPSIS

 utility --configFile config.conf ...

 utility --help

=head1 DESCRIPTION

This WebGUI utility script helps you...

=head1 ARGUMENTS

=head1 OPTIONS

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--help>

Shows a short summary and usage

=item B<--man>

Shows this document

=back

=head1 AUTHOR

Copyright 2001-2009 Plain Black Corporation.

=cut

#vim:ft=perl
