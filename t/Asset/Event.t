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
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset::Event;

use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 18;

my $session = WebGUI::Test->session;

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Adding Calendar for Event Asset Test"});
WebGUI::Test->tagsToRollback($versionTag);
my $defaultAsset = WebGUI::Asset->getDefault($session);
my $cal = $defaultAsset->addChild({className=>'WebGUI::Asset::Wobject::Calendar'});
$versionTag->commit;

my $properties = {
	#     '1234567890123456789012'
	id        => 'EventAssetTest00000001',
	title     => 'Birthday of WebGUI',
	className => 'WebGUI::Asset::Event',
	url       => 'event-asset-test1',
    startDate => '2000-08-16', ##Times and dates have to be entered in UTC
    startTime => '23:00:00',
    endDate   => '2000-08-17',
    endTime   => '03:00:00',
    timeZone  => 'America/Chicago',
    location  => 'Madison, Wisconsin',
};

my $event = $cal->addChild($properties, $properties->{id});

is($event->isAllDay, 0, 'isAllDay is zero since it has a start and end time');
cmp_ok($event->getDateTimeEnd, '>', $event->getDateTimeEndNI, 'getDateTimeEndNI is less than getDateTimeEnd');

my %templateVars = $event->getTemplateVars();
is($templateVars{isOneDay}, 1, 'getTemplateVars: isOneDay with start times');
is($templateVars{dateSpan}, 'Wednesday, August 16 6:00 PM &ndash;  10:00 PM', 'getTemplateVars: dateSpan bridges times on a single day');

$properties->{startDate} = '2000-08-16';
$properties->{endDate}   = '2000-08-16';
$properties->{startTime} = undef;
$properties->{endTime}   = undef;
$properties->{id}        = 'EventAssetTest00000002';
$properties->{url}       = 'event-asset-test2';

my $event2 = $cal->addChild($properties, $properties->{id});

is($event2->isAllDay, 1, 'isAllDay is zero since it has no start or end time');
cmp_ok($event2->getDateTimeEnd, '==', $event2->getDateTimeEndNI, 'getDateTimeEndNI is the same as getDateTimeEnd, due to no end time');

%templateVars = $event2->getTemplateVars();
is($templateVars{dateSpan}, 'Wednesday, August 16', 'getTemplateVars: dateSpan with no times');
is($templateVars{isOneDay}, 1, 'getTemplateVars: isOneDay with start times');

$properties->{startDate} = '2000-08-16';
$properties->{endDate}   = '2000-08-17';
$properties->{startTime} = undef;
$properties->{endTime}   = undef;
$properties->{id}        = 'EventAssetTest00000003';
$properties->{url}       = 'event-asset-test3';

my $event3 = $cal->addChild($properties, $properties->{id});

is($event3->isAllDay, 1, 'isAllDay is zero since it has no start or end time, even on different days');

%templateVars = $event3->getTemplateVars();
is($templateVars{dateSpan}, 'Wednesday, August 16 &bull; Thursday, August 17 ', 'getTemplateVars: dateSpan with no times, across two days');
is($templateVars{isOneDay}, 0, 'getTemplateVars: isOneDay with different start and end dates');

cmp_ok($event3->getDateTimeEnd, '==', $event3->getDateTimeEndNI, 'getDateTimeEndNI is the same as getDateTimeEnd');

$properties->{startDate} = '2000-08-30';
$properties->{endDate}   = '2000-08-31';
$properties->{startTime} = '00:00:00';
$properties->{endTime}   = '00:00:00';
$properties->{id}        = 'EventAssetTest00000004';
$properties->{url}       = 'event-asset-test4';

my $event4 = $cal->addChild($properties, $properties->{id});

cmp_ok($event4->getDateTimeEnd, '>', $event4->getDateTimeEndNI, 'getDateTimeEndNI is less than getDateTimeEnd');

is($event4->getIcalEnd, '20000831T000000Z', 'getIcalEnd, with defined time');

my $properties2 = {};
$properties2->{startDate} = '2000-08-31';
$properties2->{endDate}   = '2000-08-31';
$properties2->{id}        = 'EventAssetTest00000005';
$properties2->{url}       = 'event-asset-test5';
$properties2->{className} = 'WebGUI::Asset::Event';

my $event5 = $cal->addChild($properties2, $properties2->{id});

is($event5->getIcalStart, '20000831', 'getIcalStart, with no start time');
is($event5->getIcalEnd,   '20000901', 'getIcalEnd, with no end time, day incremented');

my $properties3 = {};
$properties3->{startDate} = '2000-08-31';
$properties3->{endDate}   = '2000-08-31';
$properties3->{id}        = 'EventAssetTestStorage6';
$properties3->{url}       = 'event-asset-test6';
$properties3->{className} = 'WebGUI::Asset::Event';

my $eventStorage = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($eventStorage);
$properties3->{storageId} = $eventStorage->getId;

my $event6 = $cal->addChild($properties3, $properties3->{id});

sleep 2;

my $event6a = $event6->addRevision({ title => 'Event with storage', }, undef, { skipAutoCommitWorkflows => 1, });
ok($session->id->valid($event6a->get('storageId')), 'addRevision gives the new revision a valid storageId');
isnt($event6a->get('storageId'), $event6->get('storageId'), '... and it is different from the previous revision');
my $versionTag2 = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->tagsToRollback($versionTag2);
