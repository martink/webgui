# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# This tests the moveField functions of the DataForm
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Asset;
use WebGUI::Asset::Wobject::DataForm;
use WebGUI::VersionTag;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# Create a DataForm
my $df  = WebGUI::Asset->getImportNode( $session )
        ->addChild( {
            className           => "WebGUI::Asset::Wobject::DataForm",
            mailData            => 0,
            fieldConfiguration  => '[]',
        } );

my $versionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->tagsToRollback($versionTag);
$versionTag->commit;

#----------------------------------------------------------------------------
# Tests

plan tests => 1;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# _createForm

WebGUI::Test->interceptLogging;

$df->_createForm(
    {
        name => 'test field',
        type => 'MASSIVE FORM FAILURE',
    },
    'some value'
);

is($WebGUI::Test::logger_error, "Unable to load form control - MASSIVE FORM FAILURE", '_createForm logs when it cannot load a form type');

#vim:ft=perl
