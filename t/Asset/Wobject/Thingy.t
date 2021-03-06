#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";

##The goal of this test is to test the creation of Thingy Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 22; # increment this value for each test you create
use Test::Deep;
use JSON;
use WebGUI::Asset::Wobject::Thingy;
use Data::Dumper;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

my $templateId = 'THING_EDIT_TEMPLATE___';
my $templateMock = Test::MockObject->new({});
$templateMock->set_isa('WebGUI::Asset::Template');
$templateMock->set_always('getId', $templateId);
my $templateVars;
$templateMock->mock('process', sub { $templateVars = $_[1]; } );

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Thingy Test"});
WebGUI::Test->tagsToRollback($versionTag);
my $thingy = $node->addChild({className=>'WebGUI::Asset::Wobject::Thingy'});

# Test for a sane object type
isa_ok($thingy, 'WebGUI::Asset::Wobject::Thingy');

# Test to see if we can set new values
my $newThingySettings = {
	templateId=>'testingtestingtesting1',
};
$thingy->update($newThingySettings);

foreach my $newSetting (keys %{$newThingySettings}) {
	is ($thingy->get($newSetting), $newThingySettings->{$newSetting}, "updated $newSetting is ".$newThingySettings->{$newSetting});
}

# Test adding a new Thing
my $i18n = WebGUI::International->new($session, "Asset_Thingy");
my $groupIdEdit = $thingy->get("groupIdEdit");
my %thingProperties = (
            thingId=>"new",
            label=>$i18n->get('assetName'),
            editScreenTitle=>$i18n->get('edit screen title label'),
            editInstructions=>'',
            groupIdAdd=>$groupIdEdit,
            groupIdEdit=>$groupIdEdit,
            saveButtonLabel=>$i18n->get('default save button label'),
            afterSave=>'searchThisThing',
            editTemplateId=>"ThingyTmpl000000000003",
            groupIdView=>$groupIdEdit,
            viewTemplateId=>"ThingyTmpl000000000002",
            defaultView=>'searchThing',
            searchScreenTitle=>$i18n->get('search screen title label'),
            searchDescription=>'',
            groupIdSearch=>$groupIdEdit,
            groupIdExport=>$groupIdEdit,
            groupIdImport=>$groupIdEdit,
            searchTemplateId=>"ThingyTmpl000000000004",
            thingsPerPage=>25,
);
my $thingId = $thingy->addThing(\%thingProperties,0); 

my $isValidId = $session->id->valid($thingId);

is($isValidId,1,"addThing returned a valid id: ".$thingId);

my $thingTableName = "Thingy_".$thingId;

my ($thingTableNameCheck) = $session->db->quickArray("show tables like ".$session->db->quote($thingTableName));

is($thingTableNameCheck,$thingTableName,"An empty table: ".$thingTableName." for the new thing exists.");

is($thingy->get('defaultThingId'),$thingId,"The Thingy assets defaultThingId was set correctly.");

# Test getting the newly added thing by its thingID as JSON

$session->user({userId => 3});
my $json = $thingy->www_getThingViaAjax($thingId);
my $dataFromJSON = JSON->new->decode($json);

cmp_deeply(
        $dataFromJSON,
        {
            assetId=>$thingy->getId,
            thingId=>$thingId,
            label=>$i18n->get('assetName'),
            editScreenTitle=>$i18n->get('edit screen title label'),
            editInstructions=>'',
            groupIdAdd=>$groupIdEdit,
            groupIdEdit=>$groupIdEdit,
            saveButtonLabel=>$i18n->get('default save button label'),
            afterSave=>'searchThisThing',
            editTemplateId=>"ThingyTmpl000000000003",
            groupIdView=>$groupIdEdit,
            viewTemplateId=>"ThingyTmpl000000000002",
            defaultView=>'searchThing',
            searchScreenTitle=>$i18n->get('search screen title label'),
            searchDescription=>'',
            groupIdSearch=>$groupIdEdit,
            groupIdExport=>$groupIdEdit,
            groupIdImport=>$groupIdEdit,
            searchTemplateId=>"ThingyTmpl000000000004",
            thingsPerPage=>25,
            display=>undef,
            onAddWorkflowId=>undef,
            onEditWorkflowId=>undef,
            onDeleteWorkflowId=>undef,
            sortBy=>undef,
            field_loop=>[],
            exportMetaData=>undef,
            maxEntriesPerUser=>undef,
        },
        'Getting newly added thing as JSON: www_getThingViaAjax returns correct data as JSON.'
    );

# Test getting all things in this Thingy as JSON, this should be an array containing only 
# the newly created thing.

$json = $thingy->www_getThingsViaAjax();
$dataFromJSON = JSON->new->decode($json);

cmp_deeply(
        $dataFromJSON,
        [{
            assetId=>$thingy->getId,
            thingId=>$thingId,
            label=>$i18n->get('assetName'),
            editScreenTitle=>$i18n->get('edit screen title label'),
            editInstructions=>'',
            groupIdAdd=>$groupIdEdit,
            groupIdEdit=>$groupIdEdit,
            saveButtonLabel=>$i18n->get('default save button label'),
            afterSave=>'searchThisThing',
            editTemplateId=>"ThingyTmpl000000000003",
            groupIdView=>$groupIdEdit,
            viewTemplateId=>"ThingyTmpl000000000002",
            defaultView=>'searchThing',
            searchScreenTitle=>$i18n->get('search screen title label'),
            searchDescription=>'',
            groupIdSearch=>$groupIdEdit,
            groupIdExport=>$groupIdEdit,
            groupIdImport=>$groupIdEdit,
            searchTemplateId=>"ThingyTmpl000000000004",
            thingsPerPage=>25,
            display=>undef,
            onAddWorkflowId=>undef,
            onEditWorkflowId=>undef,
            onDeleteWorkflowId=>undef,
            sortBy=>undef,
            canEdit=>1,
            canAdd=>1,
            canSearch=>1,
            exportMetaData=>undef,
            maxEntriesPerUser=>undef,
        }],
        'Getting all things in Thingy as JSON: www_getThingsViaAjax returns correct data as JSON.'
    );


# Test adding a field

my %fieldProperties = (
    thingId=>$thingId,
    fieldId=>"new",
    label=>$i18n->get('assetName')." field",
    dateCreated=>time(),    
    fieldType=>"textarea",
    status=>"editable",
    display=>1,
);

my $fieldId = $thingy->addField(\%fieldProperties,0);

$isValidId = $session->id->valid($fieldId);

is($isValidId,1,"Adding a textarea field: addField returned a valid id: ".$fieldId);

my ($fieldLabel, $columnType, $Null, $Key, $Default, $Extra) = $session->db->quickArray("show columns from "
                                                                .$session->db->dbh->quote_identifier($thingTableName)
                                                                ." like ".$session->db->quote("Field_".$fieldId));

is($fieldLabel,"field_".$fieldId,"A column for the new field Field_$fieldId exists.");
is($columnType,"longtext","The columns is the right type");

# Test duplicating a Thing

my $copyThingId = $thingy->duplicateThing($thingId);

$isValidId = $session->id->valid($copyThingId);

ok($isValidId, "duplicating a Thing: duplicateThing returned a valid id: ".$copyThingId);

# Test adding, editing, getting and deleting thing data

my ($newThingDataId,$errors) = $thingy->editThingDataSave($thingId,'new',{"field_".$fieldId => 'test value'});
ok( ! $thingy->hasEnteredMaxPerUser($thingId), 'hasEnteredMaxPerUser: returns false when maxEntriesPerUser=0 and 1 entry added');

my $isValidThingDataId = $session->id->valid($newThingDataId);

ok($isValidThingDataId, "Adding thing data: editFieldSave returned a valid id: ".$newThingDataId);

my $viewThingVars = $thingy->getViewThingVars($thingId,$newThingDataId);

cmp_deeply(
        $viewThingVars->{field_loop},
        [{
            field_id    => $fieldId,
            field_isHidden => "",
            field_value => 'test value',
            field_url => undef,
            field_name => "field_".$fieldId,
            field_label => $i18n->get('assetName')." field",
            field_isRequired => '',
            field_isVisible => '',
            field_pretext => undef,
            field_subtext => undef,
            field_type => "textarea",
        }],
        'Getting newly added thing data: getViewThingVars returns correct field_loop.'
    );

$json = $thingy->www_viewThingDataViaAjax($thingId,$newThingDataId);
$dataFromJSON = JSON->new->decode($json);

cmp_deeply(
        $dataFromJSON,
        {
        field_loop => [{
            field_id    => $fieldId,
            field_isHidden => "", 
            field_value => 'test value',
            field_url => undef,
            field_name => "field_".$fieldId,
            field_label => $i18n->get('assetName')." field",
            field_isRequired => '',
            field_isVisible => '',
            field_pretext => undef,
            field_subtext => undef,
            field_type => "textarea",
            }], 
        viewScreenTitle => "",
        },
        'Getting newly added thing data as JSON: www_viewThingDataViaAjax returns correct data as JSON.'
    );  

my ($updatedThingDataId,$errors) = $thingy->editThingDataSave($thingId,$newThingDataId,{"field_".$fieldId => 'new test value'});

my $viewThingVars = $thingy->getViewThingVars($thingId,$newThingDataId);

cmp_deeply(
        $viewThingVars->{field_loop},
        [{
            field_id    => $fieldId,
            field_isHidden => "",
            field_value => 'new test value',
            field_url => undef,
            field_name => "field_".$fieldId,
            field_label => $i18n->get('assetName')." field",
            field_isRequired => '',
            field_isVisible => '',
            field_pretext => undef,
            field_subtext => undef,
            field_type => "textarea",
        }],
        'Getting updated thing data: getViewThingVars returns correct field_loop with updated value.'
    );

$thingy->deleteThingData($thingId,$newThingDataId);

is($thingy->getViewThingVars($thingId,$newThingDataId),undef,'Thing data was succesfully deleted, getViewThingVars returns undef.');

$json = $thingy->www_viewThingDataViaAjax($thingId,$newThingDataId);
$dataFromJSON = JSON->new->decode($json);

cmp_deeply(
        $dataFromJSON,
        {
            message => "The thingDataId you requested can not be found.",
        },
        'Getting thing data as JSON after deleting: www_viewThingDataViaAjax returns correct message.'
    );

($newThingDataId,$errors) = $thingy->editThingDataSave($thingId,'new',{"field_".$fieldId => 'second test value'});

my %otherThingProperties = %thingProperties;
$otherThingProperties{maxEntriesPerUser} = 1;
$otherThingProperties{editTemplateId   } = $templateId;
my $otherThingId = $thingy->addThing(\%otherThingProperties, 0); 
my $otherFieldId = $thingy->addField(\%fieldProperties, 0);
ok( ! $thingy->hasEnteredMaxPerUser($otherThingId), 'hasEnteredMaxPerUser: returns false with no data entered');

my @edit_thing_form_fields = qw/form_start form_end form_submit field_loop/;

{
    WebGUI::Test->mockAssetId($templateId, $templateMock);
    $thingy->editThingData($otherThingId);
    my %miniVars;
    @miniVars{@edit_thing_form_fields} = @{ $templateVars }{ @edit_thing_form_fields };
    cmp_deeply(
        \%miniVars,
        {
            form_start  => ignore,
            form_end    => ignore,
            form_submit => ignore,
            field_loop  => ignore,
        },
        'thing edit form variables exist, because max entries not reached yet'
    );
}

$thingy->editThingDataSave($otherThingId, 'new', {"field_".$otherFieldId => 'other test value'} );
ok( $thingy->hasEnteredMaxPerUser($otherThingId), '... returns true with one row entered, and maxEntriesPerUser=1');

{
    WebGUI::Test->mockAssetId($templateId, $templateMock);
    $thingy->editThingData($otherThingId);
    my %miniVars;
    @miniVars{@edit_thing_form_fields} = @{ $templateVars }{ @edit_thing_form_fields };
    my $existance = 0;
    foreach my $tmplVar (@edit_thing_form_fields) {
        $existance ||= exists $templateVars->{$tmplVar}
    }
    ok(
        ! $existance,
        'thing edit form variables do not exist, because max entries was reached'
    );
}
